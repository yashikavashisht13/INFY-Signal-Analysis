% Step 1: Load and plot price data

data   = readtable('INFY.csv');
dates  = data.Date;
prices = data.Close;

figure;
plot(dates, prices, 'Color', [0.2 0.4 0.8], 'LineWidth', 1.2);
title('Infosys (INFY) — Historical Close Price');
xlabel('Date');
ylabel('Price (USD)');
grid on;
% Step 2: Calculate moving averages

sma50  = movmean(prices, 50);
sma200 = movmean(prices, 200);

hold on;
plot(dates, sma50,  'Color', [0.9 0.5 0.0], 'LineWidth', 1.5);
plot(dates, sma200, 'Color', [0.8 0.1 0.1], 'LineWidth', 1.8);

legend('Close Price', '50-Day MA', '200-Day MA', 'Location', 'northwest');
% Step 3: Detect crossover signals

% Find where 50MA crosses above 200MA (golden cross = buy signal)
golden = find(diff(sma50 > sma200) == 1);

% Find where 50MA crosses below 200MA (death cross = sell signal)
death  = find(diff(sma50 > sma200) == -1);

% Plot buy signals as green triangles
plot(dates(golden), prices(golden), '^', ...
    'Color', [0.0 0.6 0.0], ...
    'MarkerFaceColor', [0.0 0.6 0.0], ...
    'MarkerSize', 8);

% Plot sell signals as red triangles
plot(dates(death), prices(death), 'v', ...
    'Color', [0.8 0.0 0.0], ...
    'MarkerFaceColor', [0.8 0.0 0.0], ...
    'MarkerSize', 8);

legend('Close Price', '50-Day MA', '200-Day MA', ...
    'Golden Cross (Buy)', 'Death Cross (Sell)', ...
    'Location', 'northwest');
% Step 4: Backtesting

% Start with $1 (we track growth, not absolute dollars)
capital = 1;
equity  = ones(length(prices), 1);
in_market = false;
buy_price = 0;

for i = 2:length(prices)
    % Check if today is a buy signal
    if ismember(i, golden)
        in_market = true;
        buy_price = prices(i);
    end

    % Check if today is a sell signal
    if ismember(i, death)
        if in_market
            capital = capital * (prices(i) / buy_price);
        end
        in_market = false;
    end

    % Track portfolio value each day
    if in_market
        equity(i) = capital * (prices(i) / buy_price);
    else
        equity(i) = capital;
    end
end

% Plot equity curve in a new figure
figure;
plot(dates, equity, 'Color', [0.1 0.6 0.3], 'LineWidth', 1.5);
title('Portfolio Equity Curve — MA Crossover Strategy');
xlabel('Date');
ylabel('Portfolio Value (starting at $1)');
grid on;
% Step 5: Performance Metrics

% Total return
total_return = (equity(end) - 1) * 100;
fprintf('Total Return: %.2f%%\n', total_return);

% Maximum drawdown (worst peak-to-trough loss)
peak = cummax(equity);
drawdown = (equity - peak) ./ peak * 100;
max_drawdown = min(drawdown);
fprintf('Maximum Drawdown: %.2f%%\n', max_drawdown);

% Daily returns
daily_returns = diff(equity) ./ equity(1:end-1);

% Sharpe ratio (annualised, assuming 0% risk-free rate)
sharpe = (mean(daily_returns) / std(daily_returns)) * sqrt(252);
fprintf('Sharpe Ratio: %.2f\n', sharpe);

% Plot drawdown in a new figure
figure;
plot(dates, drawdown, 'Color', [0.8 0.1 0.1], 'LineWidth', 1.2);
title('Strategy Drawdown Over Time');
xlabel('Date');
ylabel('Drawdown (%)');
grid on;
% Step 6: Save charts and print summary

% Save all three figures as images
figure(1);
saveas(figure(1), 'INFY_Price_MA.png');

figure(2);
saveas(figure(2), 'INFY_Equity_Curve.png');

figure(3);
saveas(figure(3), 'INFY_Drawdown.png');

% Print clean project summary
fprintf('\n========================================\n');
fprintf('  INFY MA CROSSOVER — PROJECT SUMMARY\n');
fprintf('========================================\n');
fprintf('Stock        : Infosys (INFY)\n');
fprintf('Period       : 2005 – 2026\n');
fprintf('Strategy     : 50/200-Day MA Crossover\n');
fprintf('----------------------------------------\n');
fprintf('Total Return : %.2f%%\n', total_return);
fprintf('Max Drawdown : %.2f%%\n', max_drawdown);
fprintf('Sharpe Ratio : %.2f\n', sharpe);
fprintf('----------------------------------------\n');
fprintf('Buy Signals  : %d\n', length(golden));
fprintf('Sell Signals : %d\n', length(death));
fprintf('========================================\n\n');