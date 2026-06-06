INFY Financial Signal Analysis & Backtesting Engine
MATLAB | Signal Processing | Quantitative Finance
Overview
This project applies signal processing techniques from Electronics & Communication Engineering to financial time-series data. Using 20 years of Infosys (INFY) historical price data, I implemented a moving average crossover strategy, backtested it, and evaluated performance using standard quantitative finance metrics.
The core idea mirrors what ECE engineers do with noisy sensor signals — apply filters to extract the underlying trend and act on meaningful signal changes.
What I Built

Loaded and visualised 20 years of INFY historical price data (2005–2026)
Applied 50-day and 200-day Simple Moving Average filters to smooth price noise and extract trend
Detected Golden Cross (buy) and Death Cross (sell) crossover signals
Built a backtesting loop to simulate portfolio performance
Calculated key risk metrics: Total Return, Maximum Drawdown, Sharpe Ratio

Results
MetricValueStockInfosys (INFY)Period2005 – 2026Strategy50/200-Day MA CrossoverTotal Return94.14%Maximum Drawdown-45.88%Sharpe Ratio0.25Buy Signals34Sell Signals35
Key Finding
The strategy generated a 94% return over 20 years but with a Sharpe ratio of only 0.25 — indicating weak risk-adjusted performance. The worst drawdown of -45.88% occurred around the 2008 financial crisis. This is consistent with academic literature showing that simple MA crossover rules struggle to consistently outperform passive buy-and-hold strategies in efficient markets.
The ECE Connection
Moving averages are low-pass filters applied to time-series data. The same mathematical principle used to filter noise from sensor signals in ECE is applied here to financial price data — removing short-term fluctuations to reveal the underlying trend.
