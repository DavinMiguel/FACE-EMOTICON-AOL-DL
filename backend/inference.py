import onnxruntime as ort
import numpy as np
import cv2
import json
from pathlib import Path

# Load config JSON
config_path = Path(__file__).resolve().parent / "checkpoint_info.json"
config = json.load(open(config_path))

LABELS = config["labels"]
INPUT_SIZE = config["input_size"]
MODEL_FILE = config["model_file"]

# Path ke model ONNX
model_path = Path(__file__).resolve().parent.parent / "DeepLearning" / MODEL_FILE.replace(".pth", ".onnx")

# Load ONNX model
session = ort.InferenceSession(str(model_path), providers=["CPUExecutionProvider"])

# ===============================
#   FACE DETECTOR (Haar Cascade)
# ===============================
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")


def detect_face(image_path):
    """Return True jika wajah terdeteksi, False jika tidak ada wajah."""
    img = cv2.imread(image_path)
    if img is None:
        return False
        
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    faces = face_cascade.detectMultiScale(
        gray,
        scaleFactor=1.2,
        minNeighbors=5
    )

    return len(faces) > 0


def preprocess_image(image_path):
    """Membaca dan memproses gambar menjadi input tensor ONNX."""
    img = cv2.imread(image_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = cv2.resize(img, tuple(INPUT_SIZE))
    img = img.astype("float32") / 255.0
    img = np.transpose(img, (2, 0, 1))      # (H,W,C) -> (C,H,W)
    img = np.expand_dims(img, axis=0)       # (1,3,224,224)
    return img


def predict_emotion(image_path):
    """Melakukan prediksi emotion dari gambar."""
    img = preprocess_image(image_path)
    input_name = session.get_inputs()[0].name

    logits = session.run(None, {input_name: img})[0][0]

    # Softmax untuk konversi probabilitas
    exp = np.exp(logits - np.max(logits))
    probabilities = exp / exp.sum()

    idx = int(np.argmax(probabilities))
    confidence = float(probabilities[idx])

    return {
        "class_id": idx,
        "emotion": LABELS[idx],
        "confidence": confidence
    }
