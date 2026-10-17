# NeuroTrace — Continuous Physiological & Environmental Headache Tracking

> A personal health digital twin that continuously monitors physiological and environmental factors to predict headache risk and suggest preventive actions, with on-device AI that works offline.

---

## 👥 Team Details

**Team Name:** Novatriz

Member 1 :Trishna B
Mmeber 2 : Sandhiya.N
Member 3 : Baheej Umer
Member 4 : Bala Sanjay R

---

## 🏫 College / Incubator Information

- **College:** KIT - Kalaignarkarunanidhi Insittute of Technology
- **City / State:** Coimbatore, Tamil Nadu, India

---

## ❗ Problem Statement

Headaches affect people differently. Common triggers include stress, poor sleep, dehydration, heat and environmental changes. Most people do not track these factors, so they find it hard to identify their personal headache patterns. Existing solutions focus on managing pain after it starts, not on preventing future episodes.

In India, heat waves, high humidity and pollution events make these triggers worse. Individuals need a continuous, private and offline-capable way to see their headache risk before it becomes disruptive.

---

## 🧬 Digital Twin Concept

NeuroTrace builds a **personal physiological digital twin** of each user:

- **Physical entity:** the user, wearing the NeuroTrace device.
- **Data link:** live sensor data (heart rate, SpO₂, body temperature, motion, ambient temperature, humidity and pressure) streamed over BLE.
- **Virtual model:** a continuously updated profile of the user's physiological state, environment and logged headache history.
- **Intelligence:** ML models run on this virtual model to estimate the current headache risk and the likely trigger type.
- **Feedback loop:** the twin sends personalized alerts and suggestions back to the user. The user's headache logs then refine the twin over time.

---

## 🏥 Healthcare Use Case

**Example:** A college student often gets headaches during exam weeks and hot afternoons.

1. The student wears NeuroTrace through the day.
2. The device tracks rising heart rate, low activity, high ambient temperature and poor sleep.
3. The model detects a pattern that matches the student's past **stress / dehydration** headaches.
4. The app sends an early alert, such as *"High headache risk — drink water, take a 10-minute break, move to a cooler place."*
5. When a headache does occur, the student logs it. The model learns and becomes more personalized.

**Target users:** students, working professionals, outdoor workers exposed to heat, and people with recurring migraines or tension headaches.

**Headache categories predicted:**

| Label | Type |
|-------|------|
| 0 | Normal (no headache risk) |
| 1 | Tension |
| 2 | Stress |
| 3 | Sleep-deprivation |
| 4 | Caffeine-withdrawal |
| 5 | Hormonal |
| 6 | Cluster |

---

## 🛠️ Technical Stack

### Hardware
- **ESP32-C3:** main controller with built-in BLE
- **MAX30100:** heart rate and SpO₂ (PPG)
- **TMP117:** high-precision body temperature
- **BME280:** ambient temperature, humidity and pressure
- **BMI270:** motion and activity tracking

### Firmware
- C/C++ (Arduino framework) for sensor drivers and device logic
- TensorFlow Lite Micro for on-device inference

### Mobile App
- **Flutter** for the cross-platform Android/iOS app
- BLE communication with the wearable
- Live dashboard, 24-hour trend charts, headache logging, alerts and suggestions

### Cloud / Backend
- **Firebase Authentication** (anonymous auth)
- **Cloud Firestore** (asia-south1) for 1-minute telemetry and headache logs
- Per-user Firestore security rules for data privacy

### AI/ML
- Python, TensorFlow / Keras, NumPy, Pandas, scikit-learn

---

## 🤖 AI/ML Model Details

- **Inputs:** heart rate, SpO₂, body temperature, activity level, ambient temperature, humidity, pressure and time-based features.
- **Output:** headache risk and predicted headache type (7 classes, listed above).
- **Model:** [e.g. lightweight neural network / Random Forest — write what you used]
- **Training:** Python + TensorFlow/Keras.
- **Deployment:** converted to TensorFlow Lite and run with TFLite Micro on the ESP32-C3 for offline prediction.
- **Personalization:** user-logged headache events are used to adapt predictions to each person.
- **Current status:** the prototype is trained and tested on simulated sensor data. Real sensor data collection is in progress.
- **Results:** [accuracy / F1 score, if available]

---

## 🏗️ System Architecture

Sensors → Edge Device (ESP32, preprocessing + TFLite) → Mobile App (BLE) → Firebase Cloud → AI/ML Analysis → Personalized Alerts → User Action

📄 **Architecture Diagram:** 

---

## 🎥 Demo Video

▶️ **Watch here:** 

---

## 📊 Presentation

📄 **Project Presentation:** 

---

## 📁 Repository Structure

NeuroTrace/
├── firmware/      # ESP32 code
├── model/         # ML training code and .tflite model
├── app/           # Flutter app
├── dashboard/     # Web dashboard
├── docs/          # Architecture diagram and presentation PDFs
├── LICENSE
└── README.md

---

## 🚀 How to Run

1. **Firmware:** open `firmware/` in Arduino IDE, select the ESP32-C3 board and upload.
2. **App:** go to `app/`, then run `flutter pub get` and `flutter run`.
3. **Model:** go to `model/`, then run `pip install -r requirements.txt` and `python train.py`.

---

## 📜 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
