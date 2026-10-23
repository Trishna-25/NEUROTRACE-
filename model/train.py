"""
NeuroTrace - Headache Risk Model Training
-----------------------------------------
1. Generates simulated sensor data for 7 headache classes
2. Trains a small neural network (12 -> 32 -> 16 -> 7)
3. Exports the trained model as a C header (neurotrace_model.h)
   that runs directly on the ESP32 - no internet or library needed.

Run:  pip install -r requirements.txt
      python train.py
"""

import os
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.neural_network import MLPClassifier
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score

np.random.seed(42)
OUT_DIR = os.path.dirname(os.path.abspath(__file__))

FEATURES = [
    "heart_rate",   # bpm (MAX30100)
    "spo2",         # % (MAX30100)
    "skin_temp",    # C (TMP117)
    "gsr",          # raw ADC 0-4095 (higher = more stress, calibrate later)
    "activity",     # motion level from MPU6050 (0 = still)
    "env_temp",     # C (AHT20)
    "humidity",     # % (AHT20)
    "pressure",     # hPa (BMP280)
    "light",        # lux (BH1750)
    "noise",        # mic peak amplitude (INMP441)
    "sleep_hours",  # previous night's sleep (from motion + RTC)
    "hour",         # hour of day 0-23 (DS3231)
]

CLASSES = ["Normal", "Tension", "Stress", "Sleep-deprivation",
           "Caffeine-withdrawal", "Hormonal", "Cluster"]

SAMPLES_PER_CLASS = 3000


def r(lo, hi, n):
    return np.random.uniform(lo, hi, n)


def generate_class(label, n):
    # Baseline: healthy person, normal conditions
    d = {
        "heart_rate": r(62, 80, n),
        "spo2": r(96, 99, n),
        "skin_temp": r(33.0, 34.5, n),
        "gsr": r(800, 1500, n),
        "activity": r(0.5, 3.0, n),
        "env_temp": r(24, 31, n),
        "humidity": r(40, 65, n),
        "pressure": r(1008, 1016, n),
        "light": r(100, 800, n),
        "noise": r(2000, 8000, n),
        "sleep_hours": r(6.5, 8.5, n),
        "hour": np.random.randint(8, 22, n).astype(float),
    }

    if label == 1:    # Tension: still posture, heat, screen light
        d["activity"] = r(0.0, 0.6, n)
        d["heart_rate"] = r(72, 88, n)
        d["gsr"] = r(1500, 2300, n)
        d["env_temp"] = r(30, 38, n)
        d["humidity"] = r(60, 85, n)
        d["light"] = r(500, 1500, n)

    elif label == 2:  # Stress: high HR, high GSR, noisy surroundings
        d["heart_rate"] = r(85, 105, n)
        d["gsr"] = r(2300, 3500, n)
        d["noise"] = r(12000, 30000, n)

    elif label == 3:  # Sleep-deprivation: short sleep
        d["sleep_hours"] = r(2.5, 5.0, n)
        d["heart_rate"] = r(75, 90, n)
        d["activity"] = r(0.2, 1.5, n)

    elif label == 4:  # Caffeine-withdrawal: morning, low HR, sluggish
        d["hour"] = np.random.randint(7, 12, n).astype(float)
        d["heart_rate"] = r(56, 68, n)
        d["activity"] = r(0.2, 1.2, n)

    elif label == 5:  # Hormonal: raised skin temp, pressure drop
        d["skin_temp"] = r(34.6, 35.5, n)
        d["heart_rate"] = r(74, 88, n)
        d["pressure"] = r(998, 1007, n)

    elif label == 6:  # Cluster: night-time, high HR, restlessness
        d["hour"] = np.random.choice([22, 23, 0, 1, 2, 3], n).astype(float)
        d["heart_rate"] = r(85, 100, n)
        d["skin_temp"] = r(34.3, 35.2, n)
        d["activity"] = r(1.5, 4.0, n)
        d["light"] = r(0, 50, n)

    df = pd.DataFrame(d)

    # Small random noise so the data looks more realistic
    for col in FEATURES:
        if col != "hour":
            df[col] += np.random.normal(0, df[col].std() * 0.1, n)

    df["label"] = label
    return df


# ---------------- 1. Generate dataset ----------------
df = pd.concat([generate_class(i, SAMPLES_PER_CLASS) for i in range(len(CLASSES))])
df = df.sample(frac=1, random_state=42).reset_index(drop=True)
df.to_csv(os.path.join(OUT_DIR, "neurotrace_dataset.csv"), index=False)
print("Dataset created:", df.shape)

X = df[FEATURES].values.astype(np.float32)
y = df["label"].values

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, stratify=y, random_state=42)

# ---------------- 2. Normalize ----------------
mean = X_train.mean(axis=0)
std = X_train.std(axis=0)
X_train_n = (X_train - mean) / std
X_test_n = (X_test - mean) / std

# ---------------- 3. Train neural network ----------------
model = MLPClassifier(
    hidden_layer_sizes=(32, 16),
    activation="relu",
    solver="adam",
    max_iter=300,
    early_stopping=True,
    random_state=42,
)
model.fit(X_train_n, y_train)

# ---------------- 4. Evaluate ----------------
y_pred = model.predict(X_test_n)
acc = accuracy_score(y_test, y_pred)
report = classification_report(y_test, y_pred, target_names=CLASSES, digits=3)
cm = confusion_matrix(y_test, y_pred)

print(f"\nTest Accuracy: {acc * 100:.2f}%\n")
print(report)
print("Confusion Matrix:\n", cm)

with open(os.path.join(OUT_DIR, "results.txt"), "w") as f:
    f.write("NeuroTrace Headache Model - Results (simulated data)\n")
    f.write("=" * 52 + "\n\n")
    f.write("Model: neural network 12 -> 32 -> 16 -> 7 (ReLU, softmax)\n")
    f.write(f"Training samples: {len(X_train)}   Test samples: {len(X_test)}\n\n")
    f.write(f"Test Accuracy: {acc * 100:.2f}%\n\n")
    f.write(report + "\n")
    f.write("Confusion Matrix (rows = actual, columns = predicted):\n")
    f.write("Classes: " + ", ".join(CLASSES) + "\n")
    f.write(str(cm) + "\n")


# ---------------- 5. Export model as C header for ESP32 ----------------
def c_array(name, arr):
    flat = np.asarray(arr, dtype=np.float32).flatten()
    vals = [f"{v:.7f}f" for v in flat]
    lines = [", ".join(vals[i:i + 8]) for i in range(0, len(vals), 8)]
    return f"const float {name}[{len(flat)}] = {{\n  " + ",\n  ".join(lines) + "\n};\n\n"


W1, W2, W3 = model.coefs_          # shapes (12,32) (32,16) (16,7)
B1, B2, B3 = model.intercepts_
N_IN, N_H1, N_H2, N_OUT = W1.shape[0], W1.shape[1], W2.shape[1], W3.shape[1]

with open(os.path.join(OUT_DIR, "neurotrace_model.h"), "w") as f:
    f.write("// ============================================================\n")
    f.write("// NeuroTrace headache model - auto-generated by train.py\n")
    f.write(f"// Neural network {N_IN} -> {N_H1} -> {N_H2} -> {N_OUT} (ReLU, softmax)\n")
    f.write(f"// Test accuracy on simulated data: {acc * 100:.2f}%\n")
    f.write("// Runs fully on the ESP32 - no internet or extra library needed.\n")
    f.write("// ============================================================\n\n")
    f.write("#pragma once\n#include <math.h>\n\n")
    f.write(f"#define NT_NUM_FEATURES {N_IN}\n#define NT_H1 {N_H1}\n"
            f"#define NT_H2 {N_H2}\n#define NT_NUM_CLASSES {N_OUT}\n\n")
    f.write("// Input order:\n// " + ", ".join(FEATURES) + "\n\n")
    f.write("const char* NT_CLASS_NAMES[NT_NUM_CLASSES] = {"
            + ", ".join(f'"{c}"' for c in CLASSES) + "};\n\n")
    f.write(c_array("NT_MEAN", mean))
    f.write(c_array("NT_STD", std))
    f.write(c_array("NT_W1", W1))
    f.write(c_array("NT_B1", B1))
    f.write(c_array("NT_W2", W2))
    f.write(c_array("NT_B2", B2))
    f.write(c_array("NT_W3", W3))
    f.write(c_array("NT_B3", B3))
    f.write("""// Run the model.
// input[NT_NUM_FEATURES] : raw sensor values in the order above
// probs[NT_NUM_CLASSES]  : output probability for each headache type
// returns                : index of the most likely class
int neurotrace_predict(const float* input, float* probs) {
  float x[NT_NUM_FEATURES], h1[NT_H1], h2[NT_H2];

  for (int i = 0; i < NT_NUM_FEATURES; i++)
    x[i] = (input[i] - NT_MEAN[i]) / NT_STD[i];

  for (int j = 0; j < NT_H1; j++) {
    float s = NT_B1[j];
    for (int i = 0; i < NT_NUM_FEATURES; i++) s += x[i] * NT_W1[i * NT_H1 + j];
    h1[j] = s > 0 ? s : 0;
  }

  for (int j = 0; j < NT_H2; j++) {
    float s = NT_B2[j];
    for (int i = 0; i < NT_H1; i++) s += h1[i] * NT_W2[i * NT_H2 + j];
    h2[j] = s > 0 ? s : 0;
  }

  float maxv = -1e30f;
  for (int j = 0; j < NT_NUM_CLASSES; j++) {
    float s = NT_B3[j];
    for (int i = 0; i < NT_H2; i++) s += h2[i] * NT_W3[i * NT_NUM_CLASSES + j];
    probs[j] = s;
    if (s > maxv) maxv = s;
  }

  float sum = 0;
  for (int j = 0; j < NT_NUM_CLASSES; j++) { probs[j] = expf(probs[j] - maxv); sum += probs[j]; }

  int best = 0;
  for (int j = 0; j < NT_NUM_CLASSES; j++) {
    probs[j] /= sum;
    if (probs[j] > probs[best]) best = j;
  }
  return best;
}

// Overall headache risk (0-100%) = 1 - probability of "Normal"
float neurotrace_risk_percent(const float* probs) {
  return (1.0f - probs[0]) * 100.0f;
}
""")

print("\nFiles saved in:", OUT_DIR)
