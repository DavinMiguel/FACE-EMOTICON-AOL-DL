# backend/inference.py
import os
import time
import json
import requests
from pathlib import Path
from typing import Dict, Any, Optional

import onnxruntime as ort
import numpy as np
import cv2

# -----------------------
# Configuration / Paths
# -----------------------

BASE_DIR = Path(__file__).resolve().parent
CONFIG_PATH = BASE_DIR / "checkpoint_info.json"

if not CONFIG_PATH.exists():
    raise FileNotFoundError(f"checkpoint_info.json not found at {CONFIG_PATH}")

config = json.load(open(CONFIG_PATH, "r", encoding="utf-8"))

LABELS = config.get("labels", [])
INPUT_SIZE = tuple(config.get("input_size", (224, 224)))
MODEL_FILE = config.get("model_file")  # e.g. "model.pth"

# model expected inside repo at ../DeepLearning/<model>.onnx
MODEL_PATH = BASE_DIR / "DeepLearning" / MODEL_FILE.replace(".pth", ".onnx")

# Face detector assets (assumed present in backend/face_detector/)
FACE_PROTO = str(BASE_DIR / "face_detector" / "deploy.prototxt")
FACE_MODEL = str(BASE_DIR / "face_detector" / "res10_300x300_ssd_iter_140000.caffemodel")

# -----------------------
# Utility: Ensure model
# -----------------------

def download_file(url: str, dest: Path, chunk_size: int = 8192) -> None:
    """Download a file from url to dest (stream). Raises on error."""
    dest.parent.mkdir(parents=True, exist_ok=True)
    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(dest, "wb") as f:
            for chunk in r.iter_content(chunk_size=chunk_size):
                if chunk:
                    f.write(chunk)

def try_ensure_model(model_path: Path, timeout_sec: int = 20) -> bool:
    """
    Ensure the model file exists. If not present and MODEL_URL env var set,
    try to download it. Will attempt for up to timeout_sec seconds.
    Returns True if model_path exists at the end.
    """
    if model_path.exists():
        return True

    model_url = os.environ.get("MODEL_URL")
    if not model_url:
        # No remote model provided
        return False

    start = time.time()
    while time.time() - start < timeout_sec:
        try:
            print(f"[inference] downloading model from MODEL_URL to {model_path} ...")
            download_file(model_url, model_path)
            if model_path.exists():
                print("[inference] model downloaded successfully")
                return True
        except Exception as e:
            print(f"[inference] download attempt failed: {e}; retrying...")
            time.sleep(2)

    return model_path.exists()

# -----------------------
# Global session & face net
# -----------------------

session: Optional[ort.InferenceSession] = None

# Initialize face detector now (this uses static assets which should be in repo)
if not Path(FACE_PROTO).exists() or not Path(FACE_MODEL).exists():
    # We'll still create face_net but reading will fail if files missing;
    # better to raise early so logs show missing files.
    raise FileNotFoundError(f"Face detector files not found: {FACE_PROTO}, {FACE_MODEL}")

face_net = cv2.dnn.readNetFromCaffe(FACE_PROTO, FACE_MODEL)

# -----------------------
# Face detection function
# -----------------------

def detect_face_ssd(image_path: str, conf_threshold: float = 0.6) -> bool:
    """
    Return True if at least one face is detected with confidence > conf_threshold.
    """
    try:
        img = cv2.imread(image_path)
        if img is None:
            print(f"[inference] detect_face_ssd: cannot read image {image_path}")
            return False

        h, w = img.shape[:2]
        blob = cv2.dnn.blobFromImage(
            img, 1.0, (300, 300),
            (104.0, 177.0, 123.0),
            swapRB=False, crop=False
        )

        face_net.setInput(blob)
        detections = face_net.forward()

        for i in range(detections.shape[2]):
            confidence = float(detections[0, 0, i, 2])
            if confidence > conf_threshold:
                return True
    except Exception as e:
        print(f"[inference] detect_face_ssd error: {e}")
        return False

    return False

# -----------------------
# Preprocessing
# -----------------------

def preprocess_image(image_path: str) -> np.ndarray:
    """
    Read image file, convert to RGB, resize to INPUT_SIZE, normalize and reshape
    into ONNX input format (1, C, H, W).
    """
    img = cv2.imread(image_path)
    if img is None:
        raise FileNotFoundError(f"Image not found or unable to read: {image_path}")

    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, (INPUT_SIZE[0], INPUT_SIZE[1]))
    img = img.astype("float32") / 255.0
    img = np.transpose(img, (2, 0, 1))
    img = np.expand_dims(img, axis=0)
    return img

# -----------------------
# Prediction (lazy-load model)
# -----------------------

def _ensure_session() -> None:
    """Ensure the global ONNX session is initialized. Raise descriptive error if not."""
    global session
    if session is not None:
        return

    # Try to ensure model is present (maybe download from MODEL_URL)
    wait_sec_env = os.environ.get("MODEL_DOWNLOAD_WAIT")
    wait_sec = int(wait_sec_env) if wait_sec_env and wait_sec_env.isdigit() else 20

    ok = try_ensure_model(MODEL_PATH, timeout_sec=wait_sec)
    if not ok:
        raise FileNotFoundError(
            f"ONNX model not found at {MODEL_PATH}. "
            f"Set environment variable MODEL_URL to a direct download link or include the model in the image."
        )

    # create session
    print(f"[inference] creating ONNX Runtime session from {MODEL_PATH}")
    session = ort.InferenceSession(str(MODEL_PATH), providers=["CPUExecutionProvider"])
    print("[inference] ONNX Runtime session created")

def predict_emotion(image_path: str) -> Dict[str, Any]:
    """
    Predict emotion for the provided image file path.
    Returns dict: {'class_id': int, 'emotion': str, 'confidence': float}
    """
    # Ensure session is available (lazy-load)
    _ensure_session()

    img = preprocess_image(image_path)
    input_name = session.get_inputs()[0].name
    logits = session.run(None, {input_name: img})[0][0]

    # Softmax
    exp = np.exp(logits - np.max(logits))
    probabilities = exp / exp.sum()

    idx = int(np.argmax(probabilities))
    confidence = float(probabilities[idx])
    label = LABELS[idx] if idx < len(LABELS) else str(idx)

    return {
        "class_id": idx,
        "emotion": label,
        "confidence": confidence
    }

# -----------------------
# Module test utilities (optional)
# -----------------------

if __name__ == "__main__":
    # quick local test (not required in production)
    test_img = str(BASE_DIR / "test.jpg")
    print("MODEL_PATH:", MODEL_PATH)
    print("MODEL exists:", MODEL_PATH.exists())
    print("Face proto exists:", Path(FACE_PROTO).exists())
    print("Face model exists:", Path(FACE_MODEL).exists())
    if Path(test_img).exists():
        print("Detect face:", detect_face_ssd(test_img))
        try:
            print("Predict:", predict_emotion(test_img))
        except Exception as e:
            print("Predict error:", e)
    else:
        print("Place a test.jpg in backend/ to run a quick local test")
