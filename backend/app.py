from flask import Flask, request, jsonify
from flask_cors import CORS
from inference import predict_emotion, detect_face
import os

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)


@app.route("/predict", methods=["POST"])
def predict():
    # Cek apakah file dikirim
    if "image" not in request.files:
        return jsonify({"status": "error", "message": "No image uploaded"}), 400

    file = request.files["image"]

    # Simpan file sementara
    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)

    # ========== FACE DETECTION ==========
    if not detect_face(filepath):
        return jsonify({
            "status": "error",
            "message": "No face detected"
        }), 400

    # ========== EMOTION PREDICTION ==========
    result = predict_emotion(filepath)

    return jsonify({
        "status": "success",
        "emotion": result["emotion"],
        "class_id": result["class_id"],
        "confidence": result["confidence"]
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
