%% Chapter 6：系統時間響應特性 (System Time-Response Characteristics)
% 對應教材 chp6.md。本檔案為「乾淨、可直接執行版」；
% 完整教學說明（符號定義、公式推導、MATLAB 語法解說）請見 chp6.ipynb。
%
% 每一節都標註對應的教材式號與範例編號。
clear; clc; close all;

% 在 Octave 與 MATLAB 都能直接執行（MATLAB 會跳過這段）
if exist('OCTAVE_VERSION', 'builtin')
    pkg load control;
    warning('off', 'Octave:gnuplot-graphics');
    warning('off', 'Octave:fltk-graphics');
end

set(0, 'DefaultTextFontName', 'Microsoft JhengHei');
set(0, 'DefaultAxesFontName', 'Microsoft JhengHei');

%% 1. 一階系統的時間響應（教材例 6.1）
T  = 0.1;
Gs = tf(4, [1 2]);                 % 受控體 Gp(s) = 4/(s+2)
Gz = c2d(Gs, T, 'zoh');            % G(z)
Tz = feedback(Gz, 1);              % 閉迴路 T(z) = G/(1+G)

fprintf('=== 1. 一階系統（例 6.1，T = %g s）===\n', T);
[ng, dg] = tfdata(Gz, 'v');
[nt, dt] = tfdata(Tz, 'v');
fprintf('  G(z) = %.4f / (z %+.4f)    教材 0.3625/(z-0.8187)\n', ng(2), dg(2));
fprintf('  T(z) = %.4f / (z %+.4f)    教材 0.3625/(z-0.4562)\n', nt(2), dt(2));

% 教材的部分分式展開：residue 回傳 [留數, 極點, 直接項]
[r, p, kk] = residue([0.3625], [1 -1.4562 0.4562]);
fprintf('  residue 的留數 r = [%.4f; %.4f]   教材 [0.6666; -0.6666]\n', r);
fprintf('  residue 的極點 p = [%.4f; %.4f]   教材 [1.0000; 0.4562]\n', p);
fprintf('  直接項 k 是否為空：%d\n', isempty(kk));

% 與教材公式 c(kT) = 0.667*(1 - 0.4562^k) 比對
n = 0:8;
[y1, ~] = step(Tz, 0:T:8*T);
c_theory = 0.667*(1 - 0.4562.^n);
fprintf('  n     模擬 c(nT)    教材公式       差\n');
for i = 1:numel(n)
    fprintf('  %-5d %-13.6f %-14.6f %.2e\n', n(i), y1(i), c_theory(i), abs(y1(i)-c_theory(i)));
end
fprintf('  穩態值 = %.6f （教材 0.667，注意不是 1 -> 有穩態誤差）\n\n', dcgain(Tz));

%% 2. 取樣 vs 不取樣的對照（教材例 6.2）
Ta = feedback(Gs, 1);              % 拿掉取樣器與保持器的純類比閉迴路
[na, da] = tfdata(Ta, 'v');
fprintf('=== 2. 類比對照組（例 6.2）===\n');
fprintf('  Ta(s) = %g/(s %+g)    教材 4/(s+6)\n', na(2), da(2));
fprintf('  ca(t) = 0.667(1-e^{-6t})，穩態 = %.6f\n', dcgain(Ta));
fprintf('  兩者穩態相同，但暫態不同 -> 取樣只影響暫態\n\n');

figure('Name', '1-2. 取樣 vs 不取樣');
tt = 0:0.005:0.8;
[ya, ~] = step(Ta, tt);
[yd, td] = step(Tz, 0:T:0.8);
plot(tt, ya, 'b-', 'LineWidth', 1.5); hold on;
stairs(td, yd, 'r-', 'LineWidth', 2); grid on;
title('例 6.1 vs 6.2：取樣資料系統 vs 類比系統');
xlabel('時間 t (秒)'); ylabel('c(t)');
legend('類比系統（無取樣）', '取樣資料系統（T=0.1s）', 'Location', 'southeast');

%% 3. 差分方程式解法（教材例 6.4 與其 MATLAB 程式）
T4  = 1;
Gs4 = tf(1, [1 1 0]);              % Gp(s) = 1/(s(s+1))
Gz4 = c2d(Gs4, T4, 'zoh');
Tz4 = feedback(Gz4, 1);
[n4, d4] = tfdata(Tz4, 'v');

fprintf('=== 3. 二階系統與差分方程式（例 6.4，T = %g s）===\n', T4);
fprintf('  T(z) = (%.3f z + %.3f)/(z^2 %+.3f z %+.3f)\n', n4(2), n4(3), d4(2), d4(3));
fprintf('  教材 (0.368z + 0.264)/(z^2 - z + 0.632)\n\n');

% 教材的差分方程式（式 6-4）：
%   c(kT) = 0.368 r(kT-T) + 0.264 r(kT-2T) + c(kT-T) - 0.632 c(kT-2T)
% 注意最後一行的「搬移舊值」就是 z^{-1} 在程式裡的樣子
rm1 = 0; rm2 = 0; cm1 = 0; cm2 = 0;
c_diff = zeros(1, 14);
for kk2 = 1:14
    r_in = 1;                                            % 單位步階輸入
    c = 0.368*rm1 + 0.264*rm2 + cm1 - 0.632*cm2;         % 式 (6-4)
    c_diff(kk2) = c;
    cm2 = cm1; cm1 = c; rm2 = rm1; rm1 = r_in;           % 延遲一步
end

[y4, ~] = step(Tz4, 0:T4:13*T4);
fprintf('  k     差分方程式     step()        差\n');
for i = 1:14
    fprintf('  %-5d %-14.6f %-13.6f %.2e\n', i-1, c_diff(i), y4(i), abs(c_diff(i)-y4(i)));
end
fprintf('  教材列出 k=0:0, k=1:0.3680, k=11:1.0809, k=12:1.0323, k=13:0.9812\n\n');

%% 4. 由 z 平面極點反推 zeta, wn, tau（教材式 6-8~6-10，例 6.5、6.6）
fprintf('=== 4. 由 z 極點反推連續系統參數（式 6-8~6-10）===\n');

% 例 6.5：一階系統的實極點
z1 = -dt(2);                                    % = 0.4562
s1 = log(z1)/T;
fprintf('  [例 6.5] z1 = %.4f -> s1 = ln(z1)/T = %.4f  （教材 -7.848）\n', z1, s1);
fprintf('           tau = 1/|s1| = %.4f s  （教材 0.127）\n', 1/abs(s1));
fprintf('           約 4 個時間常數安定 -> %.2f s\n\n', 4/abs(s1));

% 例 6.6：二階系統的共軛複數極點
p4 = pole(Tz4);
rr = abs(p4(1));  th = abs(angle(p4(1)));       % r 與 theta（弧度）
zeta = -log(rr)/sqrt(log(rr)^2 + th^2);         % 式 (6-8)
wn   = sqrt(log(rr)^2 + th^2)/T4;               % 式 (6-9)
tau  = -T4/log(rr);                             % 式 (6-10)
fprintf('  [例 6.6] 極點 = %.4f +- j%.4f = %.4f angle +-%.2f deg (= %.4f rad)\n', ...
        real(p4(1)), abs(imag(p4(1))), rr, th*180/pi, th);
fprintf('           教材 0.5 +- j0.618 = 0.795 angle 51.0 deg = 0.890 rad\n');
fprintf('           zeta = %.4f  （教材 0.250）\n', zeta);
fprintf('           wn   = %.4f  （教材 0.9191 rad/s）\n', wn);
fprintf('           tau  = %.4f  （教材 4.36 s）\n', tau);

% 對照連續系統
pa = pole(feedback(Gs4, 1));
fprintf('\n           對照連續系統：zeta = %.4f, wn = %.4f, tau = %.4f\n', ...
        -real(pa(1))/abs(pa(1)), abs(pa(1)), 1/abs(real(pa(1))));
fprintf('           教材 0.5, 1, 2  ->  取樣的效果是「去穩定化」\n');

% T = 0.1 時取樣影響很小
Tz5 = feedback(c2d(Gs4, 0.1, 'zoh'), 1);
p5  = pole(Tz5); r5 = abs(p5(1)); th5 = abs(angle(p5(1)));
fprintf('\n           若改成 T=0.1：zeta = %.4f, wn = %.4f, tau = %.4f\n', ...
        -log(r5)/sqrt(log(r5)^2+th5^2), sqrt(log(r5)^2+th5^2)/0.1, -0.1/log(r5));
fprintf('           教材 0.475, 0.998, 2.11  ->  幾乎回到連續系統\n\n');

% 式 (6-11)、(6-12)：取樣率是否足夠
fprintf('  取樣率檢查（式 6-11、6-12）：\n');
fprintf('    每個時間常數取樣 tau/T = -1/ln(r) = %.2f 次\n', -1/log(rr));
fprintf('    每個振盪週期取樣 Td/T = 360/theta_deg = %.2f 次\n', 360/(th*180/pi));
fprintf('    （Table 6-2：r=0.8 -> 4.48 次；theta=60deg -> 6 次）\n\n');

%% 5. s 平面映射到 z 平面（教材 Fig. 6-6 ~ 6-9）
figure('Name', '5. s 平面映射到 z 平面', 'Position', [80 80 900 500]);
th_c = linspace(0, 2*pi, 400);
Tm = 1;

subplot(1,2,1);   % 等阻尼（sigma 常數）-> 圓
plot(cos(th_c), sin(th_c), 'k--', 'LineWidth', 1); hold on;
for sig = [-0.1 -0.3 -0.7 -1.5]
    rr2 = exp(sig*Tm);
    plot(rr2*cos(th_c), rr2*sin(th_c), 'LineWidth', 1.5);
end
axis equal; grid on;
title('等阻尼軌跡（\sigma 常數）-> 圓（Fig. 6-7）');
xlabel('Re(z)'); ylabel('Im(z)');
legend('單位圓', '\sigma=-0.1', '\sigma=-0.3', '\sigma=-0.7', '\sigma=-1.5', ...
       'Location', 'eastoutside');

subplot(1,2,2);   % 等阻尼比（zeta 常數）-> 對數螺線
plot(cos(th_c), sin(th_c), 'k--', 'LineWidth', 1); hold on;
for zt = [0.1 0.3 0.5 0.7]
    wn_v = linspace(0.01, pi/Tm/sqrt(1-zt^2), 300);
    s_v  = -zt*wn_v + 1j*wn_v.*sqrt(1-zt^2);
    z_v  = exp(s_v*Tm);
    plot(real(z_v), imag(z_v), 'LineWidth', 1.5);
    plot(real(z_v), -imag(z_v), 'LineWidth', 1.5);
end
axis equal; grid on;
title('等阻尼比軌跡（\zeta 常數）-> 對數螺線（Fig. 6-9）');
xlabel('Re(z)'); ylabel('Im(z)');

%% 6. 穩態精確度：系統型式、Kp、Kv（教材式 6-18~6-21，例 6.7）
fprintf('=== 6. 穩態精確度（式 6-18~6-21）===\n');
T6 = 0.1;

% 型式 0：G(z) 在 z=1 沒有極點
G0 = c2d(tf(4, [1 2]), T6, 'zoh');
Kp0 = dcgain(G0);
fprintf('  [型式 0] G(z) = 4/(s+2) 離散化\n');
fprintf('     Kp = lim G(z) = %.4f\n', Kp0);
fprintf('     步階 ess = 1/(1+Kp) = %.4f\n', 1/(1+Kp0));
fprintf('     實測 1 - dcgain(閉迴路) = %.4f\n', 1 - dcgain(feedback(G0,1)));
fprintf('     斜坡 ess = 無限大（Kv = 0）\n\n');

% 型式 1：G(z) 在 z=1 有一個極點（例 6.7，K=1）
K = 1;
G1 = c2d(tf(K, [1 1 0]), T6, 'zoh');    % K/(s(s+1))
[n1g, d1g] = tfdata(G1, 'v');
% Kv = lim_{z->1} (z-1)G(z)/T。因為分母含因式 (z-1)，先用 deconv 把它除掉，
% 剩下的部分再代 z=1 即可（避免 0/0）。
d_rest = deconv(d1g, [1 -1]);            % deconv = 多項式除法
Kv1 = polyval(n1g, 1) / polyval(d_rest, 1) / T6;
fprintf('  [型式 1] G(z) = K/(s(s+1)) 離散化，K = %g（例 6.7）\n', K);
fprintf('     G(z) 在 z=1 的極點數 N = %d\n', sum(abs(roots(d1g) - 1) < 1e-8));
fprintf('     Kv = lim (z-1)G(z)/T = %.4f   教材說 Kv = K = %g\n', Kv1, K);
fprintf('     步階 ess = 0（因為 N >= 1）\n');
fprintf('     斜坡 ess = 1/Kv = %.4f\n', 1/Kv1);
fprintf('     實測 1 - dcgain(閉迴路) = %.2e （應為 0）\n\n', 1 - dcgain(feedback(G1,1)));

%% 7. Euler 法數值積分與步長的取捨（教材 6.6 節）
fprintf('=== 7. Euler 法（矩形法則，式 6-23）===\n');
fprintf('  解 xdot + x = 0，x(0) = 1，精確解 x(t) = e^{-t}\n');
fprintf('  H        步數     Euler x(1.0)    誤差\n');
for H = [0.5 0.2 0.1 0.05 0.01 0.001]
    N = round(1/H); x = 1;
    for i = 1:N, x = x + H*(-x); end            % 式 (6-23)
    fprintf('  %-8g %-8d %-15.8f %.2e\n', H, N, x, abs(x - exp(-1)));
end
fprintf('  精確值 e^{-1} = %.8f\n', exp(-1));
fprintf('  教材：H=0.1 時 x(1.0) = 0.3487，精確 0.3678\n\n');

% 教材警告「H 過小時捨入誤差會反過來增加」。雙精度太準，要 H 極小才看得到；
% 改用單精度（single）就能清楚重現這個現象。
fprintf('  教材警告「H 過小時捨入誤差反而增加」的實測：\n');
fprintf('  H          步數         single 誤差     double 誤差\n');
for H = [1e-2 1e-3 1e-4 1e-5 1e-6 1e-7]
    N = round(1/H);
    xs = single(1); Hs = single(H);
    for i = 1:N, xs = xs + Hs*(-xs); end        % 單精度
    xd = 1;
    for i = 1:N, xd = xd + H*(-xd); end         % 雙精度
    fprintf('  %-10.0e %-12d %-15.3e %.3e\n', H, N, abs(double(xs)-exp(-1)), abs(xd-exp(-1)));
end
fprintf('  => 單精度在 H 約 1e-5 時誤差最小，再減小 H 反而急速惡化\n');
fprintf('     （截斷誤差隨 H 下降，但捨入誤差隨迭代次數上升，兩者有最佳交點）\n');
fprintf('     雙精度則要 H 更小才會看到反轉，所以本章前半的表格看不出來\n');

figure('Name', '7. Euler 法');
H = 0.1; N = 20; xe = zeros(1,N+1); xe(1) = 1;
for i = 1:N, xe(i+1) = xe(i) + H*(-xe(i)); end
te = (0:N)*H;
plot(0:0.01:2, exp(-(0:0.01:2)), 'b-', 'LineWidth', 1.5); hold on;
plot(te, xe, 'ro--', 'LineWidth', 1.5, 'MarkerFaceColor', 'r'); grid on;
title('Euler 法（矩形法則）vs 精確解，H = 0.1');
xlabel('時間 t (秒)'); ylabel('x(t)');
legend('精確解 e^{-t}', 'Euler 法', 'Location', 'northeast');

disp(' ');
disp('七個實驗全部完成，共產生 4 張圖。');
