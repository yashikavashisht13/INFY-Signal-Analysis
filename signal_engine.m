% ── INFY Financial Signal Analysis & Backtesting Engine ──────────────────────
% ECE → Finance Project | Yashika Vashisht
% Tools: MATLAB | Concepts: Signal Processing, Quantitative Finance

desktop = fullfile(getenv('USERPROFILE'), 'Desktop', filesep);

saveas(figure(1), [desktop 'INFY_Price_MA.png']);
saveas(figure(2), [desktop 'INFY_Volatility.png']);
saveas(figure(3), [desktop 'INFY_Equity_Curve.png']);
saveas(figure(4), [desktop 'INFY_Drawdown.png']);
saveas(figure(5), [desktop 'INFY_Strategy_Comparison.png']);
%% Step 1: Load and plot price data
data   = readtable('INFY.csv');
dates  = data.Date;
prices = data.Close;

figure(1);
plot(dates, prices, 'Color', [0.2 0.4 0.8], 'LineWidth', 1.2);
title('Infosys (INFY) — Historical Close Price');
xlabel('Date');
ylabel('Price (USD)');
grid on;

%% Step 2: Calculate moving averages (SMA + EMA)
sma50  = movmean(prices, 50);
sma200 = movmean(prices, 200);

% EMA-50 using exponential weighting
alpha  = 2 / (50 + 1);
ema50  = zeros(length(prices), 1);
ema50(1) = prices(1);
for i = 2:length(prices)
    ema50(i) = alpha * prices(i) + (1 - alpha) * ema50(i-1);
end

hold on;
plot(dates, sma50,  'Color', [0.9 0.5 0.0], 'LineWidth', 1.5);
plot(dates, sma200, 'Color', [0.8 0.1 0.1], 'LineWidth', 1.8);
plot(dates, ema50,  'Color', [0.1 0.8 0.5], 'LineWidth', 1.2, 'LineStyle', '--');
legend('Close Price', '50-Day SMA', '200-Day SMA', 'EMA-50', 'Location', 'northwest');

%% Step 3: Detect crossover signals (50/200)
golden = find(diff(sma50 > sma200) == 1);
death  = find(diff(sma50 > sma200) == -1);

plot(dates(golden), prices(golden), '^', ...
    'Color', [0.0 0.6 0.0], ...
    'MarkerFaceColor', [0.0 0.6 0.0], ...
    'MarkerSize', 8);
plot(dates(death), prices(death), 'v', ...
    'Color', [0.8 0.0 0.0], ...
    'MarkerFaceColor', [0.8 0.0 0.0], ...
    'MarkerSize', 8);

legend('Close Price', '50-Day SMA', '200-Day SMA', 'EMA-50', ...
    'Golden Cross (Buy)', 'Death Cross (Sell)', ...
    'Location', 'northwest');

saveas(figure(1), 'INFY_Price_MA.png');

%% Step 3b: Rolling Volatility (30-day, annualised)
volatility = movstd(prices, 30) * sqrt(252);

figure(2);
plot(dates, volatility, 'Color', [0.6 0.1 0.8], 'LineWidth', 1.2);
title('Infosys (INFY) — Annualised Rolling Volatility (30-Day)');
xlabel('Date');
ylabel('Volatility (Annualised %)');
grid on;
saveas(figure(2), 'INFY_Volatility.png');

%% Step 4: Backtesting function
function [equity, capital] = run_backtest(prices, buy_signals, sell_signals)
    capital   = 1;
    equity    = ones(length(prices), 1);
    in_market = false;
    buy_price = 0;
    for i = 2:length(prices)
        if ismember(i, buy_signals)
            in_market = true;
            buy_price = prices(i);
        end
        if ismember(i, sell_signals)
            if in_market
                capital = capital * (prices(i) / buy_price);
            end
            in_market = false;
        end
        if in_market
            equity(i) = capital * (prices(i) / buy_price);
        else
            equity(i) = capital;
        end
    end
end

%% Step 4a: Run primary backtest (50/200)
[equity, ~] = run_backtest(prices, golden, death);

%% Step 4b: Buy and Hold benchmark
bh_equity  = prices / prices(1);
bh_return  = (bh_equity(end) - 1) * 100;

%% Step 4c: Plot equity curve vs buy and hold
figure(3);
plot(dates, equity,    'Color', [0.1 0.6 0.3], 'LineWidth', 1.5);
hold on;
plot(dates, bh_equity, 'Color', [0.9 0.7 0.0], 'LineWidth', 1.5, 'LineStyle', '--');
title('Strategy vs Buy & Hold — Equity Curve');
xlabel('Date');
ylabel('Portfolio Value (starting at $1)');
legend('MA Crossover Strategy', 'Buy & Hold', 'Location', 'northwest');
grid on;
saveas(figure(3), 'INFY_Equity_Curve.png');

%% Step 5: Performance Metrics (50/200)
total_return  = (equity(end) - 1) * 100;
peak          = cummax(equity);
drawdown      = (equity - peak) ./ peak * 100;
max_drawdown  = min(drawdown);
daily_returns = diff(equity) ./ equity(1:end-1);
sharpe        = (mean(daily_returns) / std(daily_returns)) * sqrt(252);
avg_vol       = mean(volatility, 'omitnan');

figure(4);
plot(dates, drawdown, 'Color', [0.8 0.1 0.1], 'LineWidth', 1.2);
title('Strategy Drawdown Over Time');
xlabel('Date');
ylabel('Drawdown (%)');
grid on;
saveas(figure(4), 'INFY_Drawdown.png');

%% Step 5b: Win Rate
wins = 0;
total_trades = 0;
for k = 1:length(golden)
    sell_after = death(death > golden(k));
    if ~isempty(sell_after)
        total_trades = total_trades + 1;
        if prices(sell_after(1)) > prices(golden(k))
            wins = wins + 1;
        end
    end
end
if total_trades > 0
    win_rate = (wins / total_trades) * 100;
else
    win_rate = 0;
end

%% Step 6: Multiple Timeframe Comparison (20/50 vs 50/200 vs 100/200)
sma20  = movmean(prices, 20);
sma100 = movmean(prices, 100);

% 20/50 strategy
g_2050 = find(diff(sma20 > sma50) == 1);
d_2050 = find(diff(sma20 > sma50) == -1);
[eq_2050, ~] = run_backtest(prices, g_2050, d_2050);

% 100/200 strategy
g_100200 = find(diff(sma100 > sma200) == 1);
d_100200 = find(diff(sma100 > sma200) == -1);
[eq_100200, ~] = run_backtest(prices, g_100200, d_100200);

% Returns for all strategies
ret_2050   = (eq_2050(end) - 1) * 100;
ret_50200  = total_return;
ret_100200 = (eq_100200(end) - 1) * 100;

% Plot all three strategies + buy and hold
figure(5);
plot(dates, eq_2050,   'Color', [0.2 0.6 0.9], 'LineWidth', 1.3);
hold on;
plot(dates, equity,    'Color', [0.1 0.6 0.3], 'LineWidth', 1.3);
plot(dates, eq_100200, 'Color', [0.9 0.4 0.1], 'LineWidth', 1.3);
plot(dates, bh_equity, 'Color', [0.9 0.7 0.0], 'LineWidth', 1.5, 'LineStyle', '--');
title('MA Crossover Strategy Comparison — Multiple Timeframes');
xlabel('Date');
ylabel('Portfolio Value (starting at $1)');
legend('20/50 MA', '50/200 MA', '100/200 MA', 'Buy & Hold', 'Location', 'northwest');
grid on;
saveas(figure(5), 'INFY_Strategy_Comparison.png');

%% Step 7: Print Full Summary
fprintf('\n========================================\n');
fprintf('  INFY MA CROSSOVER — PROJECT SUMMARY\n');
fprintf('========================================\n');
fprintf('Stock          : Infosys (INFY)\n');
fprintf('Period         : 2005 – 2026\n');
fprintf('Strategy       : 50/200-Day MA Crossover\n');
fprintf('----------------------------------------\n');
fprintf('Total Return   : %.2f%%\n', total_return);
fprintf('Buy & Hold     : %.2f%%\n', bh_return);
fprintf('Max Drawdown   : %.2f%%\n', max_drawdown);
fprintf('Sharpe Ratio   : %.2f\n',   sharpe);
fprintf('Avg Volatility : %.2f%%\n', avg_vol);
fprintf('Win Rate       : %.1f%%\n', win_rate);
fprintf('----------------------------------------\n');
fprintf('Buy Signals    : %d\n', length(golden));
fprintf('Sell Signals   : %d\n', length(death));
fprintf('----------------------------------------\n');
fprintf('STRATEGY COMPARISON\n');
fprintf('20/50   MA Return  : %.2f%%\n', ret_2050);
fprintf('50/200  MA Return  : %.2f%%\n', ret_50200);
fprintf('100/200 MA Return  : %.2f%%\n', ret_100200);
fprintf('Buy & Hold Return  : %.2f%%\n', bh_return);
fprintf('========================================\n\n');