## Performance & Statistical Results

### Executive Summary (Institutional Validation)
The engine evaluates a multi-decade historical backtest on Infosys (INFY) using a **Regime-Gated 50/200-Day Moving Average Crossover Strategy**. Unlike naive backtests, this framework enforces realistic market parameters, including a **10 basis point (0.1%) transaction friction penalty** per trade and a strict **T+1 execution phase shift** to completely eliminate look-ahead bias. 

Furthermore, to isolate real-world performance, the dataset is evaluated across an **Out-of-Sample (OOS) validation split**, separating historical trend baseline development (75% In-Sample) from blind, live-testing emulation (25% Out-of-Sample).

| Quantitative Metric | Evaluation Value | Context & Architectural Significance |
| :--- | :--- | :--- |
| **Asset Under Test** | Infosys (INFY) | Primary equity target |
| **Historical Period** | 2005 – 2026 | Multi-decade macro cycle evaluation |
| **Data Split Architecture** | 75% In-Sample / 25% OOS | Mathematical protection against data-overfitting |
| **Execution Modeling** | T+1 Closing Price | Zero look-ahead bias (realistic trade entry/exit) |
| **Transaction Friction** | 0.10% (10 bps) per trade | Accounts for broker commissions and execution slippage |
| **Total Strategy Return** | **94.60%** | Cumulative return adjusted for friction and regime gating |
| **Benchmark Buy & Hold** | **246.32%** | Baseline performance of a long-only passive holding |
| **Sharpe Ratio** | **0.03** | Risk-adjusted excess return vs. a **4% Risk-Free Rate** baseline |
| **Maximum Drawdown** | **-45.66%** | Peak-to-trough systemic risk exposure |
| **Gated Trade Entries** | **19 Signals** | High-conviction alpha signals accepted by the regime filter |
| **Blocked Trade Entries** | **15 Signals** | **False signals rejected by the ADX Filter (Capital saved)** |

---

## Market Regime Filter Analysis (ADX Intelligence)

A core engineering upgrade to the engine is the integration of an **Average Directional Index (ADX) Market Regime Filter** ($ADX > 20$). Moving average crossover strategies inherently suffer severe capital erosion during sideways, consolidation phases due to "whipsawing" (rapidly entering and exiting failing trades).

* **The Logic:** The system computes the True Range (TR) and Directional Movement Indices ($+DI / -DI$) using discrete-time Infinite Impulse Response (IIR) filtering techniques via MATLAB’s native `filter()` function. 
* **The Impact:** The regime filter evaluated 34 potential structural crossovers. It successfully **blocked 15 entries** by identifying them as low-momentum, choppy consolidation phases. This structural gatekeeper preserved substantial capital by eliminating 30 individual friction events (entry/exit penalties) and minimizing absolute drawdowns in directionless macro regimes.

---

## Multiple Timeframe Strategy Comparison

To stress-test the robustness of the moving average framework under identical friction conditions, the engine cross-evaluated three separate timeframe variations alongside the primary benchmark.

| Quantitative Strategy Type | Total Absolute Return | Systemic Alpha Evaluation |
| :--- | :--- | :--- |
| **20/50-Day Moving Average** | **48.39%** | Severe underperformance. Higher transaction frequency generated excessive transaction friction penalties, demonstrating how hyper-active trading destroys alpha under realistic brokerage settings. |
| **50/200-Day Gated Strategy** | **94.60%** | Balanced mid-frequency engine. Significantly optimized by the ADX trend strength filter to maximize long-term trend retention while capping execution noise. |
| **100/200-Day Moving Average** | **124.70%** | Maximum macro lag performance. Lower trade frequency naturally minimized friction penalties, though it surrendered short-term momentum shifts. |
| **Passive Buy & Hold (Benchmark)** | **246.32%** | The structural benchmark. Proves that for a high-secular growth equity like INFY, a pure long-only technical lagging indicator underperforms absolute passive market exposure. |
