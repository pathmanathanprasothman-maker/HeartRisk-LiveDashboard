# ❤️ HeartRisk Live Dashboard

> **CO653 — Heart Disease Risk Prediction**
> Mamdani Fuzzy Inference System | Interactive MATLAB Dashboard v4

---

## 📌 Overview

HeartRisk LiveDashboard is a fully interactive, real-time heart disease risk prediction tool built in MATLAB. It uses a **Mamdani Fuzzy Inference System** with 5 clinical input variables and 12 fuzzy rules to compute a patient's cardiovascular risk score — all without requiring the Fuzzy Logic Toolbox.

The dashboard updates every panel **live** as you type patient values.

---

## 🖥️ Dashboard Layout

```
┌─────────────────┬────────────────────────┬──────────────────────┬──────────┐
│  PATIENT INPUTS │  MEMBERSHIP FUNCTIONS  │  RISK RADAR          │ HISTORY  │
│  Age / BP /     │  (5 live mini-plots)   │  (5-axis spider)     │  list    │
│  Chol / HR /    ├────────────────────────┼──────────────────────│  +       │
│  BMI            │  RULE ACTIVATIONS      │  OUTPUT MF           │  track   │
│                 │  (12-bar horizontal)   │  (Low/Med/High)      │          │
│  GAUGE          ├────────────────────────┼──────────────────────│          │
│  (speedometer)  │  SURFACE PLOT          │  FACTOR BAR CHART    │          │
│                 │  Age vs BP             │  (5 contributions)   │          │
│  SCORE BOX      │                        │                      │          │
└─────────────────┴────────────────────────┴──────────────────────┴──────────┘
```

---

## ✨ Features

| Feature | Description |
|---|---|
| 🎛️ **Live Inputs** | 5 input fields — type a value and press Enter to update everything instantly |
| 🌈 **Clinical Colour Coding** | Input boxes turn green / amber / red based on normal clinical ranges |
| 📊 **Membership Function Plots** | 5 mini MF plots with a live white marker showing patient position |
| 📏 **Rule Activation Bars** | 12 horizontal bars showing fuzzy rule firing strengths |
| 🌐 **3D Surface Plot** | Age vs Blood Pressure risk surface with patient dot |
| 🕸️ **Risk Radar** | Spider chart showing per-factor contributions (Age, BP, Chol, HR, BMI) |
| 📈 **Output MF** | Defuzzified output with score line across Low/Med/High zones |
| 📊 **Factor Bar Chart** | Colour-coded bars for each clinical factor |
| 🕐 **Patient History** | Save up to 10 patients, reload from list, see score trend line |
| 📄 **Export Report** | Saves a `.txt` report with all MF degrees, rule strengths, and risk score |
| ⤢ **Popup Panels** | Every chart has an expand button to open a full-size detail window |
| 🌙 **Dark Theme** | Full dark UI — easy on the eyes for clinical use |

---

## 🔢 Input Variables

| Variable | Range | Normal Range | Unit |
|---|---|---|---|
| Age | 20 – 90 | 20 – 45 | years |
| Blood Pressure | 80 – 200 | 80 – 120 | mmHg |
| Cholesterol | 100 – 400 | 100 – 200 | mg/dL |
| Heart Rate | 40 – 130 | 60 – 80 | bpm |
| BMI | 14 – 45 | 18.5 – 24.9 | kg/m² |

---

## 🧠 Fuzzy System Design

### Membership Functions
Each input has **3 fuzzy sets**: Low, Medium, High
- Trapezoidal MF (`trapmf`) for Low and High
- Triangular MF (`trimf`) for Medium

### Rule Base (12 Rules)

| # | Condition | Output |
|---|---|---|
| R1 | Age↑ AND BP↑ | HIGH RISK |
| R2 | Age↑ AND Cholesterol↑ | HIGH RISK |
| R3 | BP↑ AND Cholesterol↑ | HIGH RISK |
| R4 | Age↑ AND HR↑ | HIGH RISK |
| R5 | BP↑ AND BMI↑ | HIGH RISK |
| R6 | HR↑ AND BMI↑ | HIGH RISK (×0.9) |
| R7 | Age✓ AND BP✓ AND Chol✓ | MEDIUM RISK |
| R8 | BP✓ AND HR✓ | MEDIUM RISK |
| R9 | Chol✓ AND BMI✓ | MEDIUM RISK (×0.8) |
| R10 | Age↓ AND BP↓ AND Chol↓ | LOW RISK |
| R11 | Age↓ AND BMI↓ | LOW RISK (×0.9) |
| R12 | BP↓ AND Chol↓ AND HR↓ | LOW RISK (×0.9) |

### Risk Zones
```
0% ─────── 33% ─────── 66% ─────── 100%
    LOW        MEDIUM       HIGH
```

---

## 🚀 How to Run

1. Open MATLAB (R2020b or later)
2. Open `HeartRisk_LiveDashboard.m`
3. Press **Run** (F5) or click the green ▶ button
4. Wait ~2 seconds for the surface plot to build
5. Type patient values into the input boxes and press **Enter**

> ✅ **No Fuzzy Logic Toolbox required** — all MF and inference functions are built-in.

---

## 🖱️ How to Use

| Action | Result |
|---|---|
| Type a value → press Enter | All 10 panels update live |
| Click **↺ Reset** | Restores default values |
| Click **💾 Save** | Saves patient to history list |
| Click **📄 Export** | Generates a `.txt` report file |
| Click any **⤢ button** | Opens a full-size popup of that panel |
| Click a history entry | Reloads that patient's values |
| Click **🗑 Clear** | Clears all history |

---

## 💻 Requirements

| Requirement | Version |
|---|---|
| MATLAB | R2020b or later |
| Fuzzy Logic Toolbox | ❌ Not required |
| Operating System | Windows / macOS / Linux |
| Screen Resolution | 1600×900 or higher recommended |

---

## 📁 File Structure

```
HeartRisk-LiveDashboard/
│
├── HeartRisk_LiveDashboard.m    ← Main dashboard script (run this)
└── README.md                    ← This file
```

---

## 📋 Sample Output

```
=================================================
  HEART DISEASE RISK ASSESSMENT REPORT
  Generated: 11-Jun-2026 14:30:00
=================================================

PATIENT PARAMETERS:
  Age                 :   65.0 years
  Blood Pressure      :  155.0 mmHg
  Cholesterol         :  280.0 mg/dL
  Heart Rate          :   95.0 bpm
  BMI                 :   31.5 kg/m2

RISK SCORE  :  78.42%
RISK LEVEL  :  HIGH RISK
=================================================
```

---

## 📚 Module Information

- **Module:** CO653 — Intelligent Systems / Fuzzy Logic
- **Topic:** Mamdani Fuzzy Inference for Medical Decision Support
- **Dashboard Version:** v4 (Clean Grid Layout)

---

## 📄 License

This project is for **educational purposes** as part of the CO653 module.

---

*Built with MATLAB | No toolbox required | Dark theme dashboard*
