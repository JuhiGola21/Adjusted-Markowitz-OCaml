# Adjusted-Markowitz-OCaml


# Adjusted Markowitz Portfolio Optimisation in OCaml  
### Risk Management | Latency Measurement | Spot-Check Consistency

This project implements an **adjusted Markowitz portfolio optimisation algorithm** in **OCaml**, extended to reflect practical risk-management elements used in trading environments.  

It models how a trader or risk manager can minimise **Value at Risk (VaR)** while also controlling **transaction costs**, **portfolio exposure**, **latency**, and **data consistency** across multiple market sources.

---

## 🔍 Concept Overview

Traditional **Markowitz portfolio theory** focuses on balancing expected return and variance (risk).  
This project adjusts that framework to include **realistic trading constraints**:

| Component | Meaning | Modelled By |
|------------|----------|-------------|
| **VaR (Value at Risk)** | Measures downside risk of portfolio | `value_at_risk` |
| **Transaction Costs** | Penalises frequent or large trades | `transaction_penalty` |
| **Exposure Control** | Encourages netting (offsetting) currency pairs | `exposure_penalty` |
| **Latency Penalty** | Simulates technological optimisation—penalises slow computations | `latency_penalty` |
| **Spot-Check Consistency** | Ensures data reliability before optimisation | `spot_check_consistency` |

The resulting model better represents a **real trading environment**, where both financial and technological performance matter.

---

## ⚙️ Core Formula

The adjusted objective function is:

\[
\text{Objective} = \text{VaR} + \lambda_1(\text{Transaction Cost}) + \lambda_2(\text{Exposure}) + \lambda_3(\text{Latency})
\]

Where:
- \( \lambda_1, \lambda_2, \lambda_3 \) are weighting parameters controlling the importance of each penalty term.

The goal is to **minimise** this objective.

---

## 🧠 How It Works

### 1️⃣ Portfolio Representation
```ocaml
type portfolio = {
  weights : float list;
  cov_matrix : float array array;
  trans_costs : float list;
  exposures : float list;
}
