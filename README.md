# NeuroTrace — Continuous Physiological & Environmental Headache Tracking

> A smart wearable that builds a personal health digital twin to track headache triggers, predict headache risk early and give preventive suggestions, even without internet.

---

## 👥 Team Details

**Team Name:** Novatriz

Member 1: Trishna B
Member 2: Sandhiya N
Member 3: Baheej Umer
Member 4: Bala Sanjay R

---

## 🏫 College / Incubator Information

- **College:** KIT-Kalaignarkarunanidhi Institute of Technology
- **Department:** Electrical and Electronics Engineering
- **City / State:** Coimbatore, Tamil Nadu, India

---

## 📌 Project Title

**NeuroTrace — Continuous Physiological & Environmental Headache Tracking**

---

## ❗ Problem Statement

Headaches are among the most common health problems in India, affecting students, working professionals and outdoor workers. Triggers vary from person to person and include stress, poor sleep, dehydration, heat, humidity, bright light, noise and weather changes. Most people do not track these factors, so they cannot identify their own headache patterns or predict when the next episode may occur.

Current solutions mainly focus on treating pain after it starts. Manual headache diaries are often forgotten or filled in inaccurately, and existing wearables measure general health metrics without linking them to headache risk. Most also depend on continuous internet connectivity, which is not always available in rural areas or during heat waves, floods and other disasters common in India.

There is a need for a continuous, personalized and privacy-preserving system that builds a digital twin of the user's body and environment, identifies individual headache triggers, predicts headache risk early, and gives timely preventive suggestions, even when offline.

---

## 🧬 Digital Twin Concept

NeuroTrace builds a **personal physiological digital twin** of each user:

- **Physical entity:** the user wearing the NeuroTrace device.
- **Data link:** live sensor data (heart rate, SpO2, skin temperature, stress/GSR, motion, ambient temperature, humidity, pressure, light and noise) collected continuously.
- **Virtual model:** a continuously updated profile of the user's physiological state, surroundings and headache history.
- **Intelligence:** ML models analyze the twin to estimate current headache risk and the likely trigger type.
- **Feedback loop:** the twin sends personalized alerts back to the user through vibration, LEDs, the app and SMS. Headache logs from the user then refine the twin over time.

---

## 🏥 Healthcare Use Case

Recurring headaches are one of the most common health complaints in India. Most people only react after the pain starts and rarely know what caused it. Heat waves, high humidity, poor sleep, dehydration and stress make this worse, especially during summer and exam or work-pressure periods.

NeuroTrace acts as a personal health digital twin. It creates a live virtual model of the user's body and surroundings and uses it to predict headache risk before an episode begins.

**Example scenario:**
Priya, a college student, often gets headaches during exam weeks and on hot afternoons.

1. She wears NeuroTrace throughout the day. It continuously tracks her heart rate, SpO2, skin temperature, stress level (GSR), activity, and her surroundings, including temperature, humidity, pressure, light and noise.
2. Her digital twin notices a rising heart rate, high stress levels, low movement, high ambient heat and a short sleep the previous night.
3. The AI model compares this with her past headache history and detects a pattern that matches her stress and dehydration headaches.
4. The device vibrates and the app sends an early alert: *"High headache risk — drink water, take a short break and move to a cooler place."*
5. If she still gets a headache, she presses the button on the device or logs it in the app. Her digital twin learns from it and makes future predictions more accurate for her.

**Target users:**
- Students facing academic stress and irregular sleep
- Working professionals with long screen time and work pressure
- Outdoor workers exposed to heat and dehydration
- People with recurring migraine or tension headaches

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

**Healthcare value:**
- Shifts headache care from treatment to prevention
- Gives personalized guidance based on each user's own triggers
- Works offline through on-device processing, SD card logging and SMS alerts, which is useful in rural areas and during disasters
- Builds a long-term health record that users can share with doctors
- Reduces unnecessary painkiller use and clinic visits

---

## 🛠️ Technical Stack

NeuroTrace combines wearable hardware, embedded firmware, on-device AI, a mobile app and cloud services to build a continuously updated personal health digital twin.

### Hardware
- **ESP32** - Main controller with built-in Bluetooth Low Energy (BLE) and Wi-Fi
- **MAX30100** - Heart rate and SpO2 measurement using PPG sensing
- **DS18B20** - High-precision skin temperature sensor
- **GSR Sensor** - Galvanic skin response for stress detection
- **MPU6050** - Motion and activity tracking, also used to filter movement noise
- **BMP280** - Atmospheric pressure (weather-change trigger detection)
- **BH1750** - Ambient light level (bright-light trigger detection)
- **INMP441 (I2S microphone)** - Ambient noise level (noise trigger detection)
- **DS3231** - Real-time clock for accurate timestamps, even offline
- **MAX17048** - Battery level monitoring
- **MicroSD Card Module** - Offline local data logging
- **SIM800L (GSM)** - SMS emergency alerts without internet
- **Vibration Motor, LEDs and Push Button** - Haptic alerts, status indication and quick headache logging

### Firmware
- **C/C++ (Arduino framework)** - Sensor drivers, data collection and device logic
- **TensorFlow Lite Micro** - Runs the trained ML model directly on the ESP32 for offline risk prediction

### Connectivity
- **Bluetooth Low Energy (BLE)** - Low-power communication between the wearable and the mobile app
- **GSM (SIM800L)** - SMS alerts when internet is unavailable

### Mobile App
- **Flutter (Dart)** - Cross-platform app for Android and iOS
- **Features** - Live health dashboard, 24-hour trend charts, headache logging, risk alerts and personalized suggestions

### Cloud and Backend
- **Firebase Authentication** - Secure anonymous user login
- **Cloud Firestore (asia-south1 region)** - Real-time storage of 1-minute sensor telemetry and headache logs
- **Firestore Security Rules** - Per-user data access for privacy protection

### AI/ML Development
- **Python** - Data processing and model development
- **TensorFlow / Keras** - Model training
- **NumPy, Pandas, scikit-learn** - Data handling, feature engineering and evaluation
- **TensorFlow Lite Converter** - Converts the trained model for deployment on the ESP32

### Development Tools
- **Arduino IDE** - Firmware development and upload
- **Android Studio / VS Code** - App development
- **GitHub** - Version control and code hosting

---

## 🤖 AI/ML Model Details

- **Inputs:** heart rate, SpO2, skin temperature, GSR (stress), activity level, ambient temperature, humidity, pressure, light, noise and time-based features
- **Output:** headache risk and predicted headache type (7 classes, listed above)
- **Model:** [e.g. lightweight neural network / Random Forest — write what you used]
- **Training:** Python + TensorFlow/Keras
- **Deployment:** converted to TensorFlow Lite and run with TFLite Micro on the ESP32 for offline prediction
- **Personalization:** user-logged headache events are used to adapt predictions to each person over time
- **Current status:** the prototype is trained and tested on simulated sensor data. Real sensor data collection is in progress.
- **Results:** [accuracy / F1 score, if available]

---

## 🏗️ System Architecture

Sensors (Body + Environment) → ESP32 (Preprocessing + On-device AI) → Local Alerts (Vibration, LEDs, SMS) + SD Card Logging → Mobile App (BLE) → Firebase Cloud → AI/ML Analysis → Personalized Insights → User Action

---

## 🎥 Demo Video

▶️ **Watch here:** https://youtu.be/siJPvkqTXEU

---

## 📁 Repository Structure

    NeuroTrace/
    ├── firmware/      # ESP32 code
    ├── model/         # ML training code and .tflite model
    ├── app/           # Flutter app
    ├── docs/          # Architecture diagram and presentation PDFs
    ├── LICENSE
    └── README.md

---

## 🚀 How to Run

1. **Firmware:** open the `firmware/` folder in Arduino IDE, install the libraries listed at the top of the sketch, select the ESP32 board and upload.
2. **App:** go to `app/`, then run `flutter pub get` and `flutter run`.
3. **Model:** go to `model/`, then run `pip install -r requirements.txt` and `python train.py`.

---

## 📜 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
