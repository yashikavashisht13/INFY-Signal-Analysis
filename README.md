# INFY Quantitative Backtesting Engine
A MATLAB-based framework for evaluating regime-gated trend-following strategies on historical equity data.

## Skills Demonstrated
* **MATLAB**: Vectorized data analysis, visualization, and time-series signal processing.
* **Quantitative Finance**: Backtesting methodology, transaction-cost modeling, and risk-adjusted performance analysis.
* **Financial Research**: Out-of-sample validation, regime-gating, and empirical stress-testing.

## Key Methodological Features
* **T+1 trade execution** to reduce look-ahead bias.
* **Transaction-cost modeling** (10 bps per trade).
* **Out-of-sample validation framework**.
* **Trend-strength regime gating** using ADX.
* **Risk-adjusted evaluation** using Sharpe and Calmar ratios.
* **Drawdown and equity-curve analysis**.

## Project Overview
This repository contains a quantitative backtesting engine designed to evaluate the performance of moving-average crossover strategies on Infosys (INFY) historical price data. The framework incorporates transaction cost modeling and an ADX-based regime filter to study the trade-off between trend participation and downside risk management.

Unlike many educational backtests, the framework incorporates **T+1 execution** and **transaction-cost modeling** to reduce unrealistic performance inflation and mitigate look-ahead bias.

### Performance Summary
The following metrics reflect a backtest conducted on 20 years of INFY data. Results are adjusted for a 10 basis point (0.1%) transaction friction penalty per trade.

| Metric | 50/200-Day Gated | 100/200-Day MA | Buy & Hold |
| :--- | :--- | :--- | :--- |
| **CAGR (Annualized)** | 5.82% | 7.15% | 11.45% |
| **Sharpe Ratio** | 0.03 | 0.08 | 0.25 |
| **Max Drawdown** | -45.66% | -38.10% | -45.88% |
| **Calmar Ratio** | 0.13 | 0.19 | 0.25 |
| **Total Trades** | 19 | 12 | 0 |

Results indicate that while the gated strategy reduced drawdown and trading frequency, long-term buy-and-hold delivered superior absolute returns and risk-adjusted performance over the sample period.

---
## Repository Structure
```text
├── main.m              # Main backtesting engine and analysis logic
├── INFY.csv            # Historical equity dataset
├── figures/            # Generated performance visualizations
│   ├── INFY_Price_MA.png
│   ├── INFY_Final_Equity.png
│   ├── INFY_Drawdown.png
│   └── INFY_Strategy_Comparison.png
└── README.md           # Technical documentation and findings
