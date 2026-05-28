# 🔧 IoT-Based Predictive Maintenance System for Three-Phase Induction Motors



> A cloud-integrated predictive maintenance and remote control system for industrial three-phase induction motors. Combines **ESP32 IoT hardware**, **Firebase cloud**, and **MATLAB machine learning** to detect motor faults before failure — from anywhere in the world.

---

## 📌 Table of Contents

- [Overview](#-overview)
- [System Architecture](#-system-architecture)
- [Tech Stack](#-tech-stack)
- [Hardware Components](#-hardware-components)
- [Features](#-features)
- [ML Model Performance](#-ml-model-performance)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Results](#-results)
- [Cost Analysis](#-cost-analysis)
- [Publications & Patent](#-publications--patent)
- [Team](#-team)

---

## 🌐 Overview

Unplanned industrial motor failures cause significant downtime and safety hazards. This project tackles that with a **globally deployable, cloud-connected predictive maintenance system** that:

- Monitors real-time motor parameters (voltage, current, temperature, vibration)
- Transmits data across geographically separated locations via Firebase
- Uses a **Random Forest ML classifier** to predict motor health as `Normal`, `Warning`, or `Critical`
- Estimates **Remaining Useful Life (RUL)** using temperature degradation modeling
- Enables remote **motor speed control** via Modbus RTU over RS-485

Built on a Siemens 0.75 kW three-phase induction motor with a Delta VFD, two ESP32 nodes, and MATLAB analytics — all within a ~₹14,000 hardware budget.

---

## 🏗 System Architecture

The system is divided into three layers:

```
┌─────────────────────────────────────────────────────┐
│              DATA ACQUISITION LAYER                  │
│  ESP32 (System Side) + Sensors (ACS712, ZMPT101B,   │
│  DS18B20, MPU6050) + Delta VFD + Siemens Motor      │
└──────────────────────┬──────────────────────────────┘
                       │ Modbus RTU / RS-485
                       ▼
┌─────────────────────────────────────────────────────┐
│            CLOUD COMMUNICATION LAYER                 │
│        Firebase Realtime Database (<100ms)           │
│   Remote Controller (ESP32) ↔ Motor Node (ESP32)    │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│         DATA PROCESSING & PREDICTION LAYER           │
│  MATLAB: FFT, Feature Extraction, Random Forest,    │
│  RUL Estimation, Confusion Matrix Visualization     │
└─────────────────────────────────────────────────────┘
```

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Microcontroller | ESP32 (dual node — system + controller) |
| Communication | Modbus RTU over RS-485, Firebase REST API |
| Cloud Database | Firebase Realtime Database (NoSQL) |
| Analytics | MATLAB (Signal Processing + ML Toolbox) |
| ML Algorithm | Random Forest (via `fitcensemble`) |
| Simulation | MATLAB Simulink |
| Protocol | TIA/EIA-485-A, IEEE condition monitoring standards |

---

## ⚙️ Hardware Components

| Component | Model / Spec |
|---|---|
| Induction Motor | Siemens 1LE75010EC023AA4 — 0.75kW, 415V, 50Hz, IP55 |
| Variable Frequency Drive | Delta VFD007EL21W — 1-phase in, 3-phase out, Modbus RTU |
| Microcontroller (×2) | ESP32 — 240MHz dual-core, Wi-Fi 802.11 b/g/n, 4MB Flash |
| Current Sensor | ACS712 30A — Hall effect, 66mV/A sensitivity |
| Voltage Sensor | ZMPT101B — 0–250VAC input, ±1% accuracy |
| Temperature Sensor | DS18B20 — −55°C to +125°C, ±0.5°C, 1-Wire interface |
| Vibration Sensor | MPU-6050 — 3-axis accelerometer + gyroscope |
| RS-485 Converter | TTL–RS485 module with TVS/ESD protection |

---

## ✨ Features

- **Remote Motor Speed Control** — potentiometer-based setpoint sent over Firebase → ESP32 → Modbus RTU → Delta VFD
- **Real-Time Sensor Telemetry** — voltage, current (3-phase), temperature, vibration streamed to cloud dashboard
- **Fault Classification** — Random Forest classifies motor health into `Normal` / `Warning` / `Critical`
- **FFT-Based Analysis** — detects broken rotor bar sidebands (47 Hz / 53 Hz), bearing fault frequencies (BPFO, BPFI)
- **RUL Estimation** — linear temperature degradation model predicts time to failure threshold (80°C)
- **Fail-Safe Mechanisms** — network timeout handling and fallback logic built into firmware
- **Modular Architecture** — each layer (acquisition, cloud, ML) is independently upgradeable

---

## 📊 ML Model Performance

| Metric | Value |
|---|---|
| Algorithm | Random Forest (Ensemble Bagging) |
| Training Split | 80% train / 20% test |
| Overall Accuracy | **99.5%** (analytical) / **97%** (simulation) |
| Classes | Normal, Warning, Critical |
| Top Features | Vibration RMS, FFT Amplitude, Temperature Kurtosis |
| Cloud Latency | < 150ms |

The model was trained on simulated sensor datasets replicating real-world motor conditions under normal and fault scenarios.

> Confusion matrix and feature importance plots are available in [`/results`](./results/).

---

## 📁 Project Structure

```
IoT-Motor-Predictive-Maintenance/
│
├── README.md
│
├── matlab/
│   ├── data_preprocessing.m        # Data cleaning, normalization
│   ├── feature_extraction.m        # Time + frequency domain features
│   ├── fft_analysis.m              # Vibration & current FFT
│   ├── random_forest_classifier.m  # Model training, evaluation, confusion matrix
│   └── rul_estimation.m            # Temperature degradation + RUL prediction
│
├── esp32_firmware/
│   ├── system_side/                # Sensor acquisition + Firebase upload
│   └── controller_side/           # Speed setpoint + Modbus RTU control
│
├── docs/
│   ├── system_architecture.png
│   └── circuit_diagram.png
│
└── results/
    ├── confusion_matrix.png
    ├── vibration_fft.png
    └── rul_prediction.png
```

---

## 🚀 Getting Started

### MATLAB (Predictive Maintenance)

1. Clone the repo:
   ```bash
   git clone https://github.com/YOUR_USERNAME/IoT-Motor-Predictive-Maintenance.git
   ```

2. Open MATLAB and navigate to the `matlab/` folder.

3. Load your dataset (CSV with columns: Timestamp, Voltage_R/Y/B, Current_R/Y/B, Temperature_C, Vibration_X/Y/Z, Motor_Status):
   ```matlab
   data = readtable('3phase_induction_motor_data.csv');
   ```

4. Run scripts in order:
   ```
   data_preprocessing.m  →  feature_extraction.m  →  random_forest_classifier.m  →  rul_estimation.m
   ```

### ESP32 Firmware

1. Install [Arduino IDE](https://www.arduino.cc/en/software) with ESP32 board support.
2. Install libraries: `FirebaseESP32`, `ModbusMaster`, `OneWire`, `DallasTemperature`, `Adafruit MPU6050`.
3. Configure your Firebase credentials and Wi-Fi SSID/password in the config file.
4. Flash `system_side/` to the motor-side ESP32 and `controller_side/` to the operator-side ESP32.

---

## 📈 Results

| Test | Outcome |
|---|---|
| Remote speed control via cloud | ✅ Stable, deterministic response |
| Fault detection (simulation) | ✅ 99.5% accuracy |
| Cloud sync latency | ✅ < 150ms |
| RUL estimation | ✅ Linear degradation model validated |
| Hardware prototype | ✅ Full sensor + VFD integration confirmed |

---


## 👥 Team

| Name | Role |
|---|---|
| **Kartheesan K** (22BEE1011) | Hardware integration, ESP32 firmware, ML implementation |
| **Nakul S** | Cloud architecture, Firebase, co-author |
| **Pradeesh R** | Signal processing, MATLAB analytics, co-author |

**Guide:** Dr. Jamuna K — School of Electrical Engineering, VIT Chennai

---

## 📜 License

This project was developed as part of a B.Tech final-year project at **VIT Chennai** (November 2025). Please contact the authors before reusing or building upon this work commercially.

---

> *"Predicting failure before it happens — because downtime is not an option."*
