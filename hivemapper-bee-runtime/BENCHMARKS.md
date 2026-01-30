# 📊 Vibration Entropy Benchmarks

This document tracks the vibration floors used to validate motion truth across different road classes and vehicle types.

## 📐 Calibration Methodology
Thresholds are derived from G-RMS integration over a rolling 500ms window. To minimize false negatives in high-efficiency vehicles (EVs), Nexus prioritizes high-frequency entropy over raw amplitude.

| Profile | Environment | Validation Floor | Logic |
| :--- | :--- | :--- | :--- |
| **High-Precision** | EU Highways / EVs | **0.05 G** | Micro-jitter correlation |
| **Standard Urban** | US/EU City Roads | **0.12 G** | Road texture analysis |
| **High-Gain** | India / Rural Roads | **0.25 G** | Peak-to-peak amplitude |
| **Spoof / Static** | Desktop Simulator | **<0.01 G** | Zero-entropy state |

---
---

Orthonode Infrastructure Labs™ is a technical brand and research initiative of **Orthonode Infrastructure Labs Private Limited**, Madhya Pradesh, India (NIC 72900).
---
© 2026 Orthonode Infrastructure Labs™ · All Rights Reserved
Orthonode Infrastructure Labs™ is a technical brand and research initiative of **Orthonode Infrastructure Labs Private Limited**, Madhya Pradesh, India (NIC 72900).

