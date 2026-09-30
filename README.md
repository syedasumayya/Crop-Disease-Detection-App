# 🌿 CropGuard — Crop Disease Detection App

CropGuard is a mobile-first app that detects crop leaf diseases from a photo. Upload or capture an image of a leaf, and an AI model identifies the likely disease, shows the confidence, lists symptoms and recommended actions, and lets you download a PDF report.

- **Frontend:** Flutter (runs on Android, iOS, and web)
- **Backend:** FastAPI + TensorFlow/Keras image classifier

<!--
Add screenshots here once you have them, for example:

| Splash | Dashboard | Result |
|--------|-----------|--------|
| ![Splash](docs/screenshots/splash.png) | ![Dashboard](docs/screenshots/dashboard.png) | ![Result](docs/screenshots/result.png) |
-->

---

## ✨ Features

- **AI disease detection** — photo in, disease name and confidence out
- **Symptoms and recommended actions** for each detected condition
- **PDF report download** with the photo, diagnosis, symptoms, and actions
- **Sign up / log in** with input validation
- **Dashboard** with quick actions and recent activity
- **Scan history** with search and Healthy / Diseased filters
- **Crop care tips** guide
- **Profile** with account settings, notification preferences, help and support, and an about page
- **Phone-shaped preview** when running in a desktop browser

---

## 🧱 Tech Stack

| Layer | Technology |
|-------|------------|
| Mobile / web app | Flutter, Dart |
| Local storage | `shared_preferences` |
| Image input | `image_picker` |
| PDF reports | `pdf`, `printing` |
| HTTP | `http` |
| API server | FastAPI, Uvicorn |
| ML model | TensorFlow / Keras (`.keras` model) |
| Image processing | Pillow, NumPy |

---

## 📁 Project Structure

```
crop_disease_detection_app/
├── lib/
│   ├── main.dart                  # App entry, routing (splash vs dashboard)
│   ├── theme.dart                 # Colors, text styles, shared input/button styles
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── upload_screen.dart
│   │   ├── analyzing_screen.dart  # Calls the backend /predict endpoint
│   │   ├── result_screen.dart     # Diagnosis + PDF download
│   │   ├── history_screen.dart
│   │   ├── tips_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── account_settings_screen.dart
│   │   ├── notifications_screen.dart
│   │   ├── help_support_screen.dart
│   │   └── about_screen.dart
│   ├── utils/
│   │   ├── auth_store.dart        # Local register / login / profile storage
│   │   └── disease_lookup.dart    # Label parsing + symptoms/actions by keyword
│   └── widgets/
│       ├── app_image.dart         # Web-safe image display (bytes based)
│       └── phone_frame.dart       # Phone-shaped frame for wide screens
├── crop_backend/
│   ├── main.py                    # FastAPI server
│   ├── crop_disease_model.keras   # Trained model
│   └── labels.json                # Class index → label mapping
└── pubspec.yaml
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Python 3.9 – 3.11 (recommended for TensorFlow)
- Git

### 1. Clone the repository

```bash
git clone https://github.com/syedasumayya/Crop-Disease-Detection-App-.git
cd Crop-Disease-Detection-App-
```

### 2. Start the backend

```bash
cd crop_backend
pip install fastapi uvicorn tensorflow pillow numpy python-multipart requests
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Wait for `Model and labels loaded successfully!`, then open
<http://127.0.0.1:8000/docs> to try the API in your browser.

> Run the command from inside `crop_backend/`. The model and labels are loaded using relative paths.

### 3. Run the Flutter app

In a **second terminal**, from the project root:

```bash
flutter pub get
flutter run -d chrome --web-port 5000
```

Using a fixed `--web-port` keeps browser-saved data (accounts) between runs. Chrome assigns a new random port each time otherwise, which looks like your account disappeared.

### 4. Point the app at the backend

The backend address is set in `lib/screens/analyzing_screen.dart`:

| Where you run the app | Use this URL |
|-----------------------|--------------|
| Chrome / web | `http://127.0.0.1:8000/predict` |
| Android emulator | `http://10.0.2.2:8000/predict` |
| Real phone (same Wi-Fi) | `http://<your-PC-IP>:8000/predict` |

Keep the backend running while you use the app. If it stops, the app shows "Could not reach the server."

---

## 🔌 API Reference

### `POST /predict`

Classifies a leaf image.

- **Body:** `multipart/form-data` with a `file` field (image)
- **Response:**

```json
{
  "disease": "Strawberry___Leaf_scorch",
  "confidence": 98.1,
  "severity": 0.981
}
```

The image is resized to 224×224 and scaled to 0–1 before prediction. Labels follow the `Crop___Condition` format.

### `POST /predict-yield`

Estimates yield loss for a detected disease (currently a simple placeholder calculation, and not yet used by the app).

- **Body:** form fields `disease`, `severity`, `city`
- **Response:** estimated yield in kg per hectare and yield loss percentage

---

## 🧠 How It Works

1. The user picks a leaf photo.
2. The app sends the image to the FastAPI `/predict` endpoint.
3. The Keras model returns the most likely class and its confidence.
4. The app splits the label (for example `Strawberry___Leaf_scorch`) into crop and condition, then matches keywords such as *blight*, *rust*, *scorch*, *spot*, or *mildew* to show symptoms and recommended actions.
5. The user can download the result as a PDF.

---

## ⚠️ Current Limitations

This project is a work in progress.

- **Authentication is local only.** Accounts are stored in the browser or device with `shared_preferences`, including plain-text passwords. Replace this with real backend authentication before any real use.
- **Scan history is sample data.** Real scans are not saved yet.
- **Symptoms and actions are generic**, matched by disease keyword rather than written per disease.
- **Yield estimation is a placeholder** and is not connected to the app.
- **Notification settings** are saved on the device, but push notifications are not implemented.
- **AI results are estimates.** They are not a substitute for advice from a qualified agronomist.

---

## 📦 Notes on the Model File

GitHub rejects files larger than 100 MB. If `crop_disease_model.keras` is over that size, use [Git LFS](https://git-lfs.com):

```bash
git lfs install
git lfs track "*.keras"
git add .gitattributes
```

---

## 👩‍💻 Author

**Syeda Sumayya** — [@syedasumayya](https://github.com/syedasumayya)
