# 📈 Adjusted Markowitz Portfolio Model in OCaml

This project implements an **enhanced Markowitz Portfolio Optimization** framework in **OCaml**, integrating realistic trading constraints such as **transaction costs**, **exposure limits**, **latency penalties**, and **spot price consistency checks**.  

It blends classical portfolio theory with practical risk management considerations, simulating how optimization behaves under real-world trading conditions.

---

## 🧮 Overview

The traditional Markowitz model optimizes portfolios based solely on **expected return** and **variance**.  
This project extends that framework by introducing:

1. **Transaction Cost Penalty** — discourages high-turnover portfolios.  
2. **Exposure Penalty** — limits directional or sectoral concentration.  
3. **Latency Penalty** — accounts for the time cost of computation.  
4. **Spot Price Consistency Check** — ensures market data integrity before optimization.

---

## ⚙️ Features

| Component | Description |
|------------|-------------|
| **Portfolio Variance** | Computes variance using covariance matrices. |
| **Value-at-Risk (VaR)** | Estimates downside risk given a confidence level. |
| **Transaction Penalty** | Penalizes weights with high transaction costs. |
| **Exposure Penalty** | Penalizes large absolute exposures. |
| **Latency Measurement** | Measures computation time to simulate execution latency. |
| **Spot Check Consistency** | Validates that all spot data sources are within tolerance. |
| **Adjusted Objective** | Combines all penalties and VaR into one objective score. |

---

## 🧠 Mathematical Formulation

The adjusted optimization objective is defined as:

\[
\text{Objective} = \text{VaR}(w, \Sigma, z) + 
\lambda_1 \cdot C(w) +
\lambda_2 \cdot E(w) +
\lambda_3 \cdot L(t)
\]

Where:

\[
\text{VaR}(w, \Sigma, z) = z \sqrt{w^T \Sigma w}
\]

\[
C(w) = \sum_i |w_i| c_i \quad \text{(transaction cost penalty)}
\]

\[
E(w) = \sum_i |e_i| \quad \text{(exposure penalty)}
\]

\[
L(t) \quad \text{is a latency penalty applied if runtime exceeds 10ms}
\]

\[
\lambda_1, \lambda_2, \lambda_3 \quad \text{are regularization coefficients controlling penalty weights}
\]

---


