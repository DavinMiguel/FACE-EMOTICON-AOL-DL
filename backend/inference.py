import onnxruntime as ort
import numpy as np
import cv2
import os
from pathlib import Path

# Path model
MODEL_PATH = str(Path(__file__).resolve().parent.parent / "DeepLearning" / "emotion_resnet18.onnx")

# Load ONNX model
session = ort.InferenceSession(MODEL_PATH, providers=["CPUExecutionProvider"])

LABELS = ["Angry", "Disgust", "Fear", "Happy", "Sad", "Surprise", "Neutral"]

def preprocess_image(image_path):
    img = cv2.imread(image_path)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img = cv2.resize(img, (48, 48))
    img = img.astype("float32") / 255.0
    img = np.expand_dims(img, axis=(0, 1))  # shape (1,1,48,48)
    return img

def predict_emotion(image_path):
    img = preprocess_image(image_path)
    input_name = session.get_inputs()[0].name
    output = session.run(None, {input_name: img})[0]
    idx = np.argmax(output)

    return {
        "class_id": int(idx),
        "emotion": LABELS[idx],
        "confidence": float(np.max(output))
    }
