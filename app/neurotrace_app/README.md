# NeuroTrace app (UI, simulated data)

## Run it
1. Unzip, open the `neurotrace_app` folder in VS Code.
2. In the terminal inside that folder:
   ```
   flutter create --project-name neurotrace --platforms android,ios .
   flutter pub get
   flutter run
   ```
   `flutter create .` only adds the missing android/ios folders; it keeps these source files.
3. Needs Flutter 3.22 or newer (`flutter --version`).

## Structure
- `lib/theme/app_theme.dart` – colours, fonts, spacing (change the look here)
- `lib/widgets/` – reusable pieces: cards, risk gauge, vital tiles, charts, bottom nav
- `lib/screens/` – onboarding, connect, dashboard, guidance, trends, log, history, profile, SOS
- `lib/data/sensor_simulator.dart` – fake readings + fake model output (risk, type)
- `lib/state/app_state.dart` – app data; ticks once per second
- `lib/models/sensor_reading.dart` – BLE JSON format the ESP32 should send

## Switching to the real wearable later
Replace `SensorSimulator.next()` in `AppState` with readings parsed by
`SensorReading.fromJson(...)` from a BLE notify characteristic (flutter_blue_plus).
Type labels: 0 Normal, 1 Tension, 2 Stress, 3 Sleep-deprivation, 4 Caffeine-withdrawal, 5 Hormonal, 6 Cluster.
