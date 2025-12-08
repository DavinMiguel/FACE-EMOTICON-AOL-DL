from flask import Flask, request, jsonify
from inference import predict_emotion
import os

app = Flask(__name__)
UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/predict", methods=["POST"])
def predict():
    if "image" not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    file = request.files["image"]
    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)

    result = predict_emotion(filepath)

    return jsonify({
        "status": "success",
        "emotion": result["emotion"],
        "confidence": result["confidence"]
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
