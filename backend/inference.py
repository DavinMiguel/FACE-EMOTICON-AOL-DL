import onnxruntime as ort
import numpy as np
import cv2
import json
from pathlib import Path

# ==========================
# LOAD MODEL CONFIG
# ==========================
config_path = Path(__file__).resolve().parent / "checkpoint_info.json"
config = json.load(open(config_path))

LABELS = config["labels"]
INPUT_SIZE = config["input_size"]
MODEL_FILE = config["model_file"]

# Path ke model ONNX
model_path = Path(__file__).resolve().parent.parent / "DeepLearning" / MODEL_FILE.replace(".pth", ".onnx")

# Load ONNX Runtime model
session = ort.InferenceSession(str(model_path), providers=["CPUExecutionProvider"])


# ==========================
# SSD FACE DETECTOR (DNN)
# ==========================
FACE_PROTO = str(Path(__file__).resolve().parent / "face_detector" / "deploy.prototxt")
FACE_MODEL = str(Path(__file__).resolve().parent / "face_detector" / "res10_300x300_ssd_iter_140000.caffemodel")

face_net = cv2.dnn.readNetFromCaffe(FACE_PROTO, FACE_MODEL)


def detect_face_ssd(image_path, conf_threshold=0.6):
    """Return True jika wajah terdeteksi menggunakan SSD."""
    img = cv2.imread(image_path)
    if img is None:
        return False

    h, w = img.shape[:2]

    blob = cv2.dnn.blobFromImage(
        img, 1.0, (300, 300),
        (104.0, 177.0, 123.0),
        swapRB=False, crop=False
    )

    face_net.setInput(blob)
    detections = face_net.forward()

    # Loop semua deteksi wajah
    for i in range(detections.shape[2]):
        confidence = detections[0, 0, i, 2]

        if confidence > conf_threshold:
            return True

    return False


# ==========================
# IMAGE PREPROCESSING
# ==========================
def preprocess_image(image_path):
    img = cv2.imread(image_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, tuple(INPUT_SIZE))
    img = img.astype("float32") / 255.0
    img = np.transpose(img, (2, 0, 1))
    img = np.expand_dims(img, axis=0)
    return img


# ==========================
# EMOTION PREDICTION
# ==========================
def predict_emotion(image_path):
    img = preprocess_image(image_path)
    input_name = session.get_inputs()[0].name

    logits = session.run(None, {input_name: img})[0][0]

    # Softmax
    exp = np.exp(logits - np.max(logits))
    probabilities = exp / exp.sum()

    idx = int(np.argmax(probabilities))
    confidence = float(probabilities[idx])

    return {
        "class_id": idx,
        "emotion": LABELS[idx],
        "confidence": confidence
    }
