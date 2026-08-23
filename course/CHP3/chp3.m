%% Chapter 3：取樣與重建 (Sampling and Reconstruction)
% 對應教材 chp3.md。本檔案為「乾淨、可直接執行版」；
% 完整教學說明（符號定義、公式推導、MATLAB 語法解說）請見 chp3.ipynb。
%
% 原教材第 3 章未提供 MATLAB 程式碼，本檔為驗證章節公式而補充，
% 每一節都標註對應的教材式號。
clear; clc; close all;

% 在 Octave 與 MATLAB 都能直接執行（MATLAB 會跳過這段）
if exist('OCTAVE_VERSION', 'builtin')
    pkg load control;
    warning('off', 'Octave:gnuplot-graphics');
    warning('off', 'Octave:fltk-graphics');
end

% 設定字體以避免 Windows 下的中文亂碼
set(0, 'DefaultTextFontName', 'Microsoft JhengHei');
set(0, 'DefaultAxesFontName', 'Microsoft JhengHei');

%% 共同參數
T  = 0.1;              % 取樣週期 (s)               <- 教材符號 T
ws = 2*pi/T;           % 取樣角頻率 (rad/s)          <- ws = 2*pi/T
fprintf('取樣週期 T  = %g s\n', T);
fprintf('取樣角頻率 ws = 2*pi/T = %.4f rad/s (%.2f Hz)\n\n', ws, ws/(2*pi));

%% 1. 取樣器 + 零階保持器的時域波形（教材 Fig. 3-3）
% ZOH 定義（式 3-28）：e_n(t) = e(nT)，nT <= t < (n+1)T
t_fine = 0:T/200:1;                 % 密取樣，用來畫「連續」原訊號
e_fine = sin(2*pi*1.5*t_fine);      % 原訊號 e(t) = sin(2*pi*1.5*t)
t_k    = 0:T:1;                     % 取樣瞬間 t = kT
e_k    = sin(2*pi*1.5*t_k);         % 取樣值 e(kT)

figure('Name', '1. 取樣與零階保持');
plot(t_fine, e_fine, 'b-', 'LineWidth', 1.5); hold on;
stairs(t_k, e_k, 'r-', 'LineWidth', 2);        % stairs 才是 ZOH 的正確畫法
plot(t_k, e_k, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
grid on;
title('取樣器 + 零階保持器（式 3-28，對應 Fig. 3-3）');
xlabel('時間 t (秒)'); ylabel('振幅');
legend('原訊號 e(t)', 'ZOH 輸出（階梯狀）', '取樣值 e(kT)', 'Location', 'southwest');

%% 2. 理想取樣器的輸出 e*(t)：脈衝串（式 3-4，對應 Fig. 3-6）
% e*(t) = sum e(nT)*delta(t-nT)：箭頭長度代表「權重」而非振幅
figure('Name', '2. 理想取樣器輸出 e*(t)');
stem(t_k, e_k, 'filled', 'LineWidth', 1.5); hold on;
plot(t_fine, e_fine, 'b:', 'LineWidth', 1);
grid on;
title('理想取樣器輸出 e^*(t)：脈衝串（式 3-4）— 非物理訊號');
xlabel('時間 t (秒)'); ylabel('脈衝權重 e(nT)');
legend('e^*(t) 的脈衝權重', '原訊號 e(t)', 'Location', 'southwest');

%% 3. 星號轉換：無窮級數 vs 封閉形式（教材例 3.1）
% 定義（式 3-3）：E*(s) = sum_{n=0}^inf e(nT)*exp(-n*T*s)
% 單位步階 e(t)=u(t) 的封閉形式：E*(s) = 1/(1-exp(-T*s))，需 |exp(-T*s)|<1
s_test = 2 + 1j*3;                          % 任取一個 Re(s)>0 的測試點
N      = 2000;                              % 級數截斷項數
n      = 0:N;
E_series = sum(1 .* exp(-n*T*s_test));      % e(nT)=1（單位步階）
E_closed = 1 / (1 - exp(-T*s_test));
fprintf('=== 3. 星號轉換驗證（例 3.1，單位步階）===\n');
fprintf('  測試點 s = %g + %gj，|exp(-T*s)| = %.6f (需 < 1)\n', ...
        real(s_test), imag(s_test), abs(exp(-T*s_test)));
fprintf('  級數前 %d 項  = %.8f %+.8fj\n', N+1, real(E_series), imag(E_series));
fprintf('  封閉形式      = %.8f %+.8fj\n', real(E_closed), imag(E_closed));
fprintf('  誤差          = %.2e\n\n', abs(E_series - E_closed));

%% 4. 兩個訊號、同一組取樣值（教材 Fig. 3-9）
% 取 w1 = ws/4，則 cos(w1*t) 與 cos(3*w1*t) 在所有取樣瞬間值相同
w1 = ws/4;
t_c   = 0:T/300:6*T;
y1    = cos(w1*t_c);
y2    = cos(3*w1*t_c);
tk_c  = 0:T:6*T;
y1k   = cos(w1*tk_c);
y2k   = cos(3*w1*tk_c);

figure('Name', '4. 兩訊號同一組取樣值');
plot(t_c, y1, 'b-', 'LineWidth', 1.5); hold on;
plot(t_c, y2, 'r--', 'LineWidth', 1.5);
plot(tk_c, y1k, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
grid on;
title('混疊的起源：cos(\omega_1t) 與 cos(3\omega_1t) 取樣值相同（Fig. 3-9）');
xlabel('時間 t (秒)'); ylabel('振幅');
legend('e_1(t)=cos(\omega_1 t)', 'e_2(t)=cos(3\omega_1 t)', '共同的取樣值', ...
       'Location', 'southeast');
fprintf('=== 4. 兩訊號取樣值比較（w1 = ws/4）===\n');
fprintf('  兩組取樣值最大差異 = %.2e  => 完全相同，取樣後無法分辨\n\n', ...
        max(abs(y1k - y2k)));

%% 5. Shannon 取樣定理：取樣率足夠 vs 不足
f_sig  = 3;                       % 訊號頻率 3 Hz
t_true = 0:0.0005:1;
x_true = sin(2*pi*f_sig*t_true);

fs_ok  = 20;   Ts_ok  = 1/fs_ok;  % 20 Hz > 2*3 Hz，足夠
fs_bad = 4;    Ts_bad = 1/fs_bad; % 4 Hz  < 2*3 Hz，不足 -> 混疊
tk_ok  = 0:Ts_ok:1;   xk_ok  = sin(2*pi*f_sig*tk_ok);
tk_bad = 0:Ts_bad:1;  xk_bad = sin(2*pi*f_sig*tk_bad);
f_alias = abs(f_sig - fs_bad);    % 摺返後看起來的頻率

figure('Name', '5. Shannon 取樣定理', 'Position', [100 100 900 600]);
subplot(2,1,1);
plot(t_true, x_true, 'b-', 'LineWidth', 1.2); hold on;
stem(tk_ok, xk_ok, 'r', 'filled'); grid on;
title(sprintf('取樣率足夠：f_s = %g Hz > 2f_0 = %g Hz', fs_ok, 2*f_sig));
xlabel('時間 (秒)'); ylabel('振幅');
subplot(2,1,2);
plot(t_true, x_true, 'b-', 'LineWidth', 1.2); hold on;
stem(tk_bad, xk_bad, 'r', 'filled');
plot(t_true, sin(2*pi*f_alias*t_true), 'g--', 'LineWidth', 1.5); grid on;
title(sprintf('取樣率不足：f_s = %g Hz < 2f_0 = %g Hz，看起來變成 %g Hz', ...
      fs_bad, 2*f_sig, f_alias));
xlabel('時間 (秒)'); ylabel('振幅');
legend('真實 3 Hz 訊號', '取樣值', sprintf('混疊後的 %g Hz', f_alias), ...
       'Location', 'southwest');

%% 6. 零階保持器的頻率響應（式 3-32、3-33，對應 Fig. 3-13）
w = linspace(1e-6, 3*ws, 3000);      % 從接近 0 開始，避開 0/0
x = pi*w/ws;                          % 式中反覆出現的 pi*w/ws
sinc_safe = sin(x)./x;                % omega=0 時極限為 1（起點取 1e-6 已避開）
mag_h0 = T*abs(sinc_safe);                       % 式 (3-32)
Gh0    = T*sinc_safe.*exp(-1j*x);                % 式 (3-31)
pha_h0 = angle(Gh0)*180/pi;                      % 式 (3-33)，轉成度

figure('Name', '6. ZOH 頻率響應', 'Position', [100 100 900 600]);
subplot(2,1,1);
plot(w/ws, mag_h0, 'b-', 'LineWidth', 1.5); grid on;
title('零階保持器振幅響應 |G_{h0}(j\omega)| = T|sin(\pi\omega/\omega_s)/(\pi\omega/\omega_s)|（式 3-32）');
xlabel('\omega / \omega_s'); ylabel('振幅');
subplot(2,1,2);
plot(w/ws, pha_h0, 'b-', 'LineWidth', 1.5); grid on;
title('零階保持器相位響應（式 3-33）');
xlabel('\omega / \omega_s'); ylabel('相位 (度)');

fprintf('=== 6. ZOH 頻率響應重點 ===\n');
fprintf('  omega -> 0 時 |Gh0| = %.6f  (理論值 T = %g)\n', mag_h0(1), T);
[~, iz] = min(abs(w - ws));
fprintf('  omega = ws 時 |Gh0| = %.2e  (理論上為 0，sinc 的零點)\n\n', mag_h0(iz));

%% 7. 一階保持器頻率響應，與 ZOH 比較（式 3-37、3-38，對應 Fig. 3-17）
mag_h1 = T*sqrt(1 + 4*pi^2*w.^2./ws^2).*(sinc_safe).^2;      % 式 (3-37)
pha_h1 = (atan(2*pi*w/ws) - 2*pi*w/ws)*180/pi;               % 式 (3-38)

figure('Name', '7. ZOH vs FOH 頻率響應', 'Position', [100 100 900 600]);
subplot(2,1,1);
plot(w/ws, mag_h0, 'b-', 'LineWidth', 1.5); hold on;
plot(w/ws, mag_h1, 'r--', 'LineWidth', 1.5); grid on;
title('振幅響應比較：零階保持器 vs 一階保持器');
xlabel('\omega / \omega_s'); ylabel('振幅');
legend('ZOH |G_{h0}|（式 3-32）', 'FOH |G_{h1}|（式 3-37）', 'Location', 'northeast');
subplot(2,1,2);
plot(w/ws, pha_h0, 'b-', 'LineWidth', 1.5); hold on;
plot(w/ws, pha_h1, 'r--', 'LineWidth', 1.5); grid on;
title('相位響應比較');
xlabel('\omega / \omega_s'); ylabel('相位 (度)');
legend('ZOH（式 3-33）', 'FOH（式 3-38）', 'Location', 'southwest');

% 教材結論：零頻率附近 FOH 較接近理想低通濾波器，較大 omega 則 ZOH 較好。
% 理想低通濾波器：通帶內振幅 = T 且「相位 = 0」，阻帶內振幅 = 0。
% 下表顯示 FOH 的優勢主要在「相位」而不是振幅。
fprintf('=== 7. ZOH vs FOH（教材結論的數值佐證）===\n');
fprintf('  理想低通濾波器：通帶 |G|=T=%g 且相位=0；阻帶 |G|=0\n', T);
fprintf('  %-9s %-11s %-11s %-14s %s\n', 'w/ws', '|Gh0|', '|Gh1|', 'ang Gh0(deg)', 'ang Gh1(deg)');
for r = [0.05 0.10 0.30 0.50 0.60]
    [~, ii] = min(abs(w/ws - r));
    fprintf('  %-9.2f %-11.5f %-11.5f %-14.2f %.2f\n', ...
            r, mag_h0(ii), mag_h1(ii), pha_h0(ii), pha_h1(ii));
end
fprintf('  => 低頻：FOH 相位落後遠小於 ZOH（w/ws=0.05 時約 -0.6 度 vs -9 度），\n');
fprintf('     這才是教材所說「零頻附近 FOH 較接近理想低通濾波器」的意思；\n');
fprintf('     振幅上反而是 ZOH 較平坦（更接近 T）。\n');
fprintf('  => 高頻：ZOH 振幅衰減較乾淨、相位也較佳；FOH 在中頻會把訊號放大。\n\n');

%% 8. 分數階保持器（式 3-39，對應 Fig. 3-19）
% Ghk(s) = (1-k*exp(-T*s))*(1-exp(-T*s))/s + k/(T*s^2)*(1-exp(-T*s))^2
% k=0 -> ZOH，k=1 -> FOH
figure('Name', '8. 分數階保持器', 'Position', [100 100 900 500]);
k_list = [0 0.2 0.6 1];
colors = {'b', 'g', 'm', 'r'};
hold on;
for ii = 1:numel(k_list)
    k  = k_list(ii);
    sj = 1j*w;                                   % s = j*omega
    E1 = 1 - exp(-T*sj);                         % (1 - exp(-T*s))
    Ghk = (1 - k*exp(-T*sj)).*E1./sj + (k/T)*(E1.^2)./(sj.^2);   % 式 (3-39)
    plot(w/ws, abs(Ghk), colors{ii}, 'LineWidth', 1.5);
end
grid on;
title('分數階保持器振幅響應 |G_{hk}(j\omega)|（式 3-39，對應 Fig. 3-19）');
xlabel('\omega / \omega_s'); ylabel('振幅');
legend('k = 0（即 ZOH）', 'k = 0.2', 'k = 0.6', 'k = 1（即 FOH）', 'Location', 'northeast');

% 驗證兩個端點確實退化成 ZOH 與 FOH
sj = 1j*w; E1 = 1 - exp(-T*sj);
Ghk0 = (1 - 0*exp(-T*sj)).*E1./sj + (0/T)*(E1.^2)./(sj.^2);
Ghk1 = (1 - 1*exp(-T*sj)).*E1./sj + (1/T)*(E1.^2)./(sj.^2);
fprintf('=== 8. 分數階保持器端點驗證（式 3-39）===\n');
fprintf('  k=0 與 ZOH 振幅最大差異 = %.2e\n', max(abs(abs(Ghk0) - mag_h0)));
fprintf('  k=1 與 FOH 振幅最大差異 = %.2e\n\n', max(abs(abs(Ghk1) - mag_h1)));

%% 9. ZOH 等效於半個取樣週期的延遲（式 3-33 的線性相位項）
% 式 (3-31) 的相位因子 exp(-j*pi*w/ws)，而 pi/ws = T/2
% 所以線性相位部分 = 純延遲 T/2 的相位 exp(-j*w*T/2)
pha_zoh_linear = -(pi*w/ws)*180/pi;          % ZOH 的線性相位項
pha_pure_delay = -(w*T/2)*180/pi;            % 純延遲 T/2 的相位
fprintf('=== 9. ZOH 的 T/2 等效延遲驗證 ===\n');
fprintf('  pi/ws = %.6f，T/2 = %.6f，差異 = %.2e\n', pi/ws, T/2, abs(pi/ws - T/2));
fprintf('  兩條相位曲線最大差異 = %.2e 度  => ZOH 等效引入 T/2 = %g 秒的延遲\n', ...
        max(abs(pha_zoh_linear - pha_pure_delay)), T/2);

figure('Name', '9. ZOH 的 T/2 等效延遲');
plot(w/ws, pha_zoh_linear, 'b-', 'LineWidth', 2); hold on;
plot(w/ws, pha_pure_delay, 'r--', 'LineWidth', 2); grid on;
title('ZOH 的線性相位 = 純延遲 T/2 的相位');
xlabel('\omega / \omega_s'); ylabel('相位 (度)');
legend('ZOH 線性相位項 -\pi\omega/\omega_s', '純延遲 T/2 的相位 -\omega T/2', ...
       'Location', 'southwest');

disp('九個實驗全部完成，共產生 7 張圖。');
