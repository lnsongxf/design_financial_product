clc;clear;
%% setting
r = 0.02;T = 1;cash = 700;
ex_rate = xlsread('USD_CNY.xlsx', 'B4:B1302');
ui = log(ex_rate(2:end)./ex_rate(1:end-1));
%% GARCH Model
Md = garch(1,1);
[EstMd, EstParamCov, logL] = estimate(Md, ui);
w = EstMd.Constant
a = EstMd.ARCH{1} 
b = EstMd.GARCH{1}
LRV = EstMd.UnconditionalVariance
H_VAR = var(ui)
%% Monte Carlo simulation of conditional variance models
Md1 = garch('Constant', w, 'GARCH', b, 'ARCH', a);
rng default; %for reproducibility
V = simulate(Md1, 365, 'NumPaths', 10000)';
plot(V')
title('Simulated Conditional Variances');
%% pricing
cross = 0;
for i = 1:10000
    if V(i,end) < H_VAR * 0.85
        cross = cross + 1;
    end
end
p = cross / 10000
CONP = p * cash * exp(-r * T)
price = - CONP + 1000 * exp(-r * T)