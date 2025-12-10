import requests

# URL backend Flask 
url = "http://127.0.0.1:5000/predict"
image_path = "tes2.jpg"  

# Buka file gambar dalam mode binary
files = {"image": open(image_path, "rb")}

# Kirim POST request
response = requests.post(url, files=files)

# Tampilkan hasil prediksi
print("Status code:", response.status_code)
print(response.json())
