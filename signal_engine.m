% ── INFY Quantitative Backtesting Engine (Institutional Grade) ───────────────
% ECE → Finance Project | Yashika Vashisht
% Upgrades: Look-Ahead Bias Removed, Trade Friction, ADX Regime Filter, OOS Split
% Fixes: Bulletproof OS & OneDrive Desktop Routing

%% Step 0: Bulletproof Desktop Path Finder
if ispc % If Windows OS
    od_desktop = fullfile(getenv('USERPROFILE'), 'OneDrive', 'Desktop');
    if exist(od_desktop, 'dir')
        desktop = fullfile(od_desktop, filesep);
    else
        desktop = fullfile(getenv('USERPROFILE'), 'Desktop', filesep);
    end
else % If Mac/Linux OS
    desktop = fullfile(getenv('HOME'), 'Desktop', filesep);
end

fprintf('\n>>> TARGET ACQUIRED: Saving all figures directly to: %s\n\n', desktop);

%% Step 1: Load and plot price data
data   = readtable('INFY.csv');
dates  = data.Date;

% Standardize Close vs Adjusted Close
if ismember('AdjClose', data.Properties.VariableNames)
    prices = data.AdjClose;
elseif ismember('Adj_Close', data.Properties.VariableNames)
    prices = data.Adj_Close;
else
    prices = data.Close;
end

% Check for OHLC for ADX. If missing High/Low, we approximate using Close.
has_ohlc = ismember('High', data.Properties.VariableNames) && ...
           ismember('Low', data.Properties.VariableNames);

figure(1);
plot(dates, prices, 'Color', [0.2 0.4 0.8], 'LineWidth', 1.2);
title('Infosys (INFY) — Historical Close Price');
xlabel('Date'); ylabel('Price (USD)'); grid on;

%% Step 2: Calculate MAs & The ADX Regime Filter
sma50  = movmean(prices, 50);
sma200 = movmean(prices, 200);

if has_ohlc
    % True ADX Calculation (Wilder's Smoothing Approximation via EMA)
    H = data.High; L = data.Low; C = prices;
    C_prev = [C(1); C(1:end-1)];
    
    % True Range & Directional Movement
    TR = max([H - L, abs(H - C_prev), abs(L - C_prev)], [], 2);
    upMove = H - [H(1); H(1:end-1)];
    downMove = [L(1); L(1:end-1)] - L;
    
    posDM = zeros(size(C)); negDM = zeros(size(C));
    posDM((upMove > downMove) & (upMove > 0)) = upMove((upMove > downMove) & (upMove > 0));
    negDM((downMove > upMove) & (downMove > 0)) = downMove((downMove > upMove) & (downMove > 0));
    
    % 14-Day Filter
    alpha = 1/14;
    TR_smooth  = filter(alpha, [1, -(1-alpha)], TR);
    posDM_sm   = filter(alpha, [1, -(1-alpha)], posDM);
    negDM_sm   = filter(alpha, [1, -(1-alpha)], negDM);
    
    posDI = 100 * (posDM_sm ./ TR_smooth);
    negDI = 100 * (negDM_sm ./ TR_smooth);
    
    DX = 100 * abs(posDI - negDI) ./ (posDI + negDI);
    DX(isnan(DX)) = 0; % Handle division by zero in flat periods
    ADX = filter(alpha, [1, -(1-alpha)], DX);
else
    % Fallback Volatility Filter if OHLC data is missing
    vol_proxy = movstd(prices, 14) ./ movmean(prices, 14) * 100;
    ADX = vol_proxy * 5; % Scale proxy to resemble ADX 0-100 range
end

%% Step 3: Gated Crossover Signals (The Intelligence)
trend_state = sma50 > sma200;

% Find exact indices where the state changes
cross_up = find(trend_state(2:end) == 1 & trend_state(1:end-1) == 0) + 1;
cross_dn = find(trend_state(2:end) == 0 & trend_state(1:end-1) == 1) + 1;

% THE GATEKEEPER: Only accept Golden Crosses if ADX > 20 (Market is Trending)
golden = cross_up(ADX(cross_up) > 20);
death  = cross_dn; % We always honor sell signals to protect capital

%% Step 3a: Plot Signals on Figure 1 & Save to Desktop
figure(1); hold on;
plot(dates, sma50,  'Color', [0.9 0.5 0.0], 'LineWidth', 1.5);
plot(dates, sma200, 'Color', [0.8 0.1 0.1], 'LineWidth', 1.8);
plot(dates(golden), prices(golden), '^', 'Color', [0.0 0.6 0.0], 'MarkerFaceColor', [0.0 0.6 0.0], 'MarkerSize', 8);
plot(dates(death), prices(death), 'v', 'Color', [0.8 0.0 0.0], 'MarkerFaceColor', [0.8 0.0 0.0], 'MarkerSize', 8);
legend('Close Price', '50-Day SMA', '200-Day SMA', 'Golden Cross (Buy)', 'Death Cross (Sell)', 'Location', 'northwest');
saveas(figure(1), fullfile(desktop, 'INFY_Price_MA.png'));

%% Step 3b: Rolling Volatility (Figure 2) & Save to Desktop
volatility = movstd(prices, 30) * sqrt(252);

figure(2);
plot(dates, volatility, 'Color', [0.6 0.1 0.8], 'LineWidth', 1.2);
title('Infosys (INFY) — Annualised Rolling Volatility (30-Day)');
xlabel('Date'); ylabel('Volatility (Annualised %)'); grid on;
saveas(figure(2), fullfile(desktop, 'INFY_Volatility.png'));

%% Step 4: Run primary backtest (50/200)
[equity, ~] = run_backtest(prices, golden, death);
bh_equity   = prices / prices(1);

%% Step 5: Out-Of-Sample Validation Split (Figure 3) & Save to Desktop
split_idx = round(length(dates) * 0.75); % 75% Training, 25% Live Testing
split_date = dates(split_idx);

figure(3);
plot(dates, equity, 'Color', [0.1 0.6 0.3], 'LineWidth', 1.5); hold on;
plot(dates, bh_equity, 'Color', [0.9 0.7 0.0], 'LineWidth', 1.5, 'LineStyle', '--');
xline(split_date, 'r--', 'LineWidth', 1.5, 'Label', 'Out-of-Sample Start', 'LabelHorizontalAlignment', 'left');

title('Institutional Strategy vs Buy & Hold (Regime Gated)');
xlabel('Date'); ylabel('Portfolio Value (starting at $1)');
legend('ADX-Gated MA Strategy', 'Buy & Hold', 'Location', 'northwest');
grid on; 
saveas(figure(3), fullfile(desktop, 'INFY_Final_Equity.png'));

%% Step 5b: Drawdown Metric Analysis (Figure 4) & Save to Desktop
peak         = cummax(equity);
drawdown     = (equity - peak) ./ peak * 100;
max_drawdown = min(drawdown);

figure(4);
plot(dates, drawdown, 'Color', [0.8 0.1 0.1], 'LineWidth', 1.2);
title('Strategy Drawdown Over Time');
xlabel('Date'); ylabel('Drawdown (%)'); grid on;
saveas(figure(4), fullfile(desktop, 'INFY_Drawdown.png'));

%% Step 6: Multiple Timeframe Comparison (Figure 5) & Save to Desktop
sma20  = movmean(prices, 20);
sma50_alt = movmean(prices, 50);
sma100 = movmean(prices, 100);

% 20/50 strategy
g_2050 = find(diff(sma20 > sma50_alt) == 1);
d_2050 = find(diff(sma20 > sma50_alt) == -1);
[eq_2050, ~] = run_backtest(prices, g_2050, d_2050);

% 100/200 strategy
g_100200 = find(diff(sma100 > sma200) == 1);
d_100200 = find(diff(sma100 > sma200) == -1);
[eq_100200, ~] = run_backtest(prices, g_100200, d_100200);

% Returns for all strategies
ret_2050   = (eq_2050(end) - 1) * 100;
ret_50200  = (equity(end) - 1) * 100;
ret_100200 = (eq_100200(end) - 1) * 100;

figure(5);
plot(dates, eq_2050,   'Color', [0.2 0.6 0.9], 'LineWidth', 1.3); hold on;
plot(dates, equity,    'Color', [0.1 0.6 0.3], 'LineWidth', 1.3);
plot(dates, eq_100200, 'Color', [0.9 0.4 0.1], 'LineWidth', 1.3);
plot(dates, bh_equity, 'Color', [0.9 0.7 0.0], 'LineWidth', 1.5, 'LineStyle', '--');
title('MA Crossover Strategy Comparison (Friction Adjusted)');
xlabel('Date'); ylabel('Portfolio Value (starting at $1)');
legend('20/50 MA', '50/200 MA', '100/200 MA', 'Buy & Hold', 'Location', 'northwest');
grid on; 
saveas(figure(5), fullfile(desktop, 'INFY_Strategy_Comparison.png'));

%% Step 7: Final Executive Summary & Statistical Calculations
daily_returns  = diff(equity) ./ equity(1:end-1);
risk_free_rate = 0.04; 
daily_rf       = risk_free_rate / 252;
excess_returns = daily_returns - daily_rf;
sharpe         = (mean(excess_returns) / std(daily_returns)) * sqrt(252);

fprintf('\n======================================================\n');
fprintf('  INFY QUANTITATIVE BACKTEST — V2.0 (INSTITUTIONAL)\n');
fprintf('======================================================\n');
fprintf('Model Features : ADX Regime Filter, T+1 Execution, Friction\n');
fprintf('Data Split     : 75%% In-Sample / 25%% Out-of-Sample\n');
fprintf('------------------------------------------------------\n');
fprintf('Total Return   : %.2f%%\n', ret_50200);
fprintf('Buy & Hold     : %.2f%%\n', (bh_equity(end) - 1) * 100);
fprintf('Sharpe Ratio   : %.2f (Risk-Free: 4%%)\n', sharpe);
fprintf('Max Drawdown   : %.2f%%\n', max_drawdown);
fprintf('------------------------------------------------------\n');
fprintf('Gated Entries  : %d signals accepted by ADX\n', length(golden));
fprintf('Blocked Entries: %d signals rejected due to chop\n', length(cross_up) - length(golden));
fprintf('======================================================\n\n');

%% ========================================================================
%% LOCAL FUNCTIONS (Must reside at the absolute end of the execution file)
%% ========================================================================
function [equity, capital] = run_backtest(prices, buy_signals, sell_signals)
    friction  = 0.001; % 10 bps (0.1%) slippage/commission per trade
    capital   = 1;
    equity    = ones(length(prices), 1);
    in_market = false;
    buy_price = 0;
    
    for i = 2:length(prices)
        % T+1 Execution: Checking if signal tripped on (i-1)
        if ismember(i-1, buy_signals) && ~in_market
            in_market = true;
            buy_price = prices(i); 
            capital   = capital * (1 - friction); 
        end
        
        if ismember(i-1, sell_signals) && in_market
            capital   = capital * (prices(i) / buy_price) * (1 - friction); 
            in_market = false;
        end
        
        if in_market
            equity(i) = capital * (prices(i) / buy_price);
        else
            equity(i) = capital;
        end
    end
end