%% Chapter 8：數位控制器設計 (Digital Controller Design)
% 對應教材 chp8.md。本檔案為「乾淨、可直接執行版」；
% 完整教學說明（符號定義、公式推導、MATLAB 語法解說）請見 chp8.ipynb。
%
% 每一節都標註對應的教材式號與範例編號。
%
% ⚠️ 重要：教材的設計程式用 [mag,ph]=bode(Gz,ww1) 取相位，但 Octave 的 bode
%    對「含 z=1 極點」的離散系統相位是錯的（見 chp7.m 附錄）。本章受控體含
%    純積分器，因此一律改用 freqresp。
clear; clc; close all;

if exist('OCTAVE_VERSION', 'builtin')
    pkg load control;
    warning('off', 'Octave:gnuplot-graphics');
    warning('off', 'Octave:fltk-graphics');
end

% 把本檔所在目錄加入路徑，這樣從任何位置執行都找得到
% 同目錄的輔助函數檔 w2z_filter.m 與 my_margin.m
this_dir = fileparts(mfilename('fullpath'));
if ~isempty(this_dir), addpath(this_dir); end

set(0, 'DefaultTextFontName', 'Microsoft JhengHei');
set(0, 'DefaultAxesFontName', 'Microsoft JhengHei');

%% 共同設定（教材例 8.1 ~ 8.5 全部使用同一個受控體）
% 雷達天線伺服系統，假設電樞電感不可忽略 -> 三階
%   Gp(s) = 1/(s(s+1)(0.5s+1)) = 2/(s^3+3s^2+2s)
% 最快時間常數 0.5 s，取 T 為其十分之一（教材的經驗法則）
Gp = tf([2], [1 3 2 0]);
T  = 0.05;
Gz = c2d(Gp, T, 'zoh');
Pm_want = 55;                       % 期望相位裕度（教材全章都用 55 度）

fprintf('受控體 Gp(s) = 1/(s(s+1)(0.5s+1))，T = %g s，目標相位裕度 %g deg\n\n', T, Pm_want);

%% 1. 受控體頻率響應（重現教材 Table 8-1）
fprintf('=== 1. 受控體頻率響應（Table 8-1）===\n');
fprintf('  %-8s %-10s %-10s %-11s %s\n', 'w', '|G|', '|G| dB', 'ang G(deg)', '教材 ang G');
book_w  = [0.1 0.2 0.36 0.4 0.7 1.0 1.2 1.37 2.0];
book_ph = [-98.7 -107.3 -120.5 -123.7 -145.3 -163.0 -172.9 -180.3 -201.4];
for i = 1:numel(book_w)
    H  = freqresp(Gz, book_w(i));   % ⚠️ 用 freqresp 不用 bode
    ph = angle(H)*180/pi;
    if ph > 0, ph = ph - 360; end   % angle 回傳 (-180,180]；相位低於 -180 後會跳成正值，這裡展開
    fprintf('  %-8.2f %-10.4f %-10.2f %-11.2f %.1f\n', ...
            book_w(i), abs(H), 20*log10(abs(H)), ph, book_ph(i));
end
fprintf('\n');

%% 2. 相位落後補償設計（教材例 8.1，式 8-20、8-21）
fprintf('=== 2. 相位落後補償（例 8.1）===\n');
a0 = 1;                              % 補償器直流增益（由穩態規格決定）
% 步驟 1：找 ang G = -180 + Pm + 5 = -120 度的頻率
ww1_lag = 0.36;
H  = freqresp(Gz, ww1_lag);
mg = abs(H);  pg = angle(H)*180/pi;
fprintf('  步驟1：ww1 = %.3f，|G| = %.4f（教材 2.57），ang G = %.2f deg（教材 -120.5）\n', ...
        ww1_lag, mg, pg);
% 步驟 2、3
ww0 = 0.1*ww1_lag;                                    % 式 (8-20)
wwp = 0.1*ww1_lag/(a0*mg);                            % 式 (8-21)
fprintf('  步驟2：ww0 = 0.1*ww1 = %.4f    （教材 0.036）\n', ww0);
fprintf('  步驟3：wwp = 0.1*ww1/(a0|G|) = %.5f （教材 0.0140）\n', wwp);
fprintf('  分類：ww0 (%.4f) > wwp (%.5f)  ->  確實是「相位落後」\n', ww0, wwp);
% 式 (8-14)、(8-15) 轉回 z 平面
Dz_lag = w2z_filter(a0, ww0, wwp, T);
[nd, dd] = tfdata(Dz_lag, 'v');
fprintf('  D(z) = %.4f(z - %.4f)/(z - %.4f)\n', nd(1), -nd(2)/nd(1), -dd(2));
fprintf('  教材 D(z) = 0.3890(z - 0.9982)/(z - 0.9993)\n');
[gm, pm] = my_margin(Dz_lag*Gz, T);
fprintf('  補償後：GM = %.1f dB（教材 16.8），PM = %.1f deg（教材 55.9）\n\n', gm, pm);

%% 3. 相位超前補償設計（教材例 8.2，式 8-32、8-33）
fprintf('=== 3. 相位超前補償（例 8.2）===\n');
ww1_lead = 1.2;
H  = freqresp(Gz, ww1_lead);
mg = abs(H);  pg = angle(H)*180/pi;
fprintf('  ww1 = %.1f，|G| = %.4f（教材 0.4574），ang G = %.2f deg（教材 -172.9）\n', ...
        ww1_lead, mg, pg);
phi_d = 180 + Pm_want - pg;  phi = phi_d*pi/180;      % 式 (8-32)
fprintf('  phi = 180 + %g - (%.2f) = %.1f deg = %.1f deg（教材 47.9）\n', ...
        Pm_want, pg, phi_d, mod(phi_d, 360));
fprintf('  三個約束檢查：\n');
fprintf('    1) ang G = %.2f < 180+Pm = %g       -> %s\n', pg, 180+Pm_want, ...
        merge(pg < 180+Pm_want, '通過', '不通過'));
fprintf('    2) |G| = %.4f < 1/a0 = %g          -> %s\n', mg, 1/a0, ...
        merge(mg < 1/a0, '通過', '不通過'));
fprintf('    3) cos(phi) = %.4f > a0|G| = %.4f  -> %s\n', cos(phi), a0*mg, ...
        merge(cos(phi) > a0*mg, '通過', '不通過'));
a1 = (1 - a0*mg*cos(phi))/(ww1_lead*mg*sin(phi));     % 式 (8-33a)
b1 = (cos(phi) - a0*mg)/(ww1_lead*sin(phi));          % 式 (8-33b)
fprintf('  a1 = %.4f（教材 1.703），b1 = %.4f（教材 0.2397）\n', a1, b1);
ww0_ld = a0/a1;  wwp_ld = 1/b1;                       % 式 (8-30)
fprintf('  ww0 = a0/a1 = %.4f，wwp = 1/b1 = %.4f\n', ww0_ld, wwp_ld);
fprintf('  分類：ww0 (%.4f) < wwp (%.4f)  ->  確實是「相位超前」\n', ww0_ld, wwp_ld);
Dz_lead = w2z_filter(a0, ww0_ld, wwp_ld, T);
[nd, dd] = tfdata(Dz_lead, 'v');
fprintf('  D(z) = %.4f(z - %.4f)/(z - %.4f)\n', nd(1), -nd(2)/nd(1), -dd(2));
fprintf('  教材 D(z) = 6.5278(z - 0.9711)/(z - 0.8111)\n');
[gm, pm] = my_margin(Dz_lead*Gz, T);
fprintf('  補償後：GM = %.1f dB（教材 12.4），PM = %.1f deg（教材 55.0）\n\n', gm, pm);

%% 4. PI 控制器設計（教材例 8.4，式 8-56 ~ 8-58、8-52）
fprintf('=== 4. PI 控制器（例 8.4）===\n');
Dz_pi = [];
for ww1 = [0.4 0.3]
    H  = freqresp(Gz, ww1);
    mg = abs(H);  pg = angle(H)*180/pi;
    phi = (-180 + Pm_want - pg)*pi/180;               % 式 (8-56)
    KD = 0;                                           % PI -> KD = 0
    KP = cos(phi)/mg;                                 % 式 (8-57)
    KI = -ww1*sin(phi)/mg;                            % 由式 (8-58) 且 KD=0
    Dz = KP + (KI*T/2)*tf([1 1],[1 -1],T) + (KD/T)*tf([1 -1],[1 0],T);   % 式 (8-52)
    [nd, ~] = tfdata(Dz, 'v');
    [gm, pm] = my_margin(Dz*Gz, T);
    fprintf('  ww1 = %.1f：|G| = %.4f，ang G = %.2f deg\n', ww1, mg, pg);
    fprintf('    KP = %.4f，KI = %.4f，ww0 = KI/KP = %.4f\n', KP, KI, KI/KP);
    fprintf('    D(z) = (%.4fz %+.4f)/(z - 1)\n', nd(1), nd(2));
    fprintf('    GM = %.1f dB，PM = %.1f deg\n', gm, pm);
    if ww1 == 0.4, Dz_pi = Dz; end
end
fprintf('  教材 ww1=0.4：KP=0.4392，KI=0.0040，ww0=0.0092，D(z)=(0.4393z-0.4391)/(z-1)，GM=16.0\n');
fprintf('  教材 ww1=0.3：KP=0.3125，KI=0.0154，ww0=0.0493，D(z)=(0.3129z-0.3121)/(z-1)，GM=18.4\n\n');

%% 5. 係數量化問題（教材 8.4 節的警告）
fprintf('=== 5. 係數量化問題（8.4 節的警告）===\n');
[nl, dl] = tfdata(Dz_lag,  'v');
[ne, de] = tfdata(Dz_lead, 'v');
fprintf('  相位落後 D(z)：零點 %.4f，極點 %.4f，間距 %.4f  <- 幾乎重合\n', ...
        -nl(2)/nl(1), -dl(2), abs(-nl(2)/nl(1) - (-dl(2))));
fprintf('  相位超前 D(z)：零點 %.4f，極點 %.4f，間距 %.4f  <- 分得很開\n\n', ...
        -ne(2)/ne(1), -de(2), abs(-ne(2)/ne(1) - (-de(2))));
% 模擬定點量化：把分母係數 0.9993 量化成 0.99609375（教材舉的例子）
fprintf('  教材的例子：分母係數 0.999300 若被量化成 0.99609375\n');
Dz_q = nl(1)*tf([1 nl(2)/nl(1)], [1 -0.99609375], T);
[gm0, pm0] = my_margin(Dz_lag*Gz, T);
[gmq, pmq] = my_margin(Dz_q*Gz, T);
fprintf('    量化前：GM = %.2f dB，PM = %.2f deg\n', gm0, pm0);
fprintf('    量化後：GM = %.2f dB，PM = %.2f deg\n', gmq, pmq);
fprintf('  => 相位落後濾波器的極零點幾乎重合，位置非常關鍵；\n');
fprintf('     相位超前濾波器極零點分得很開，小幅偏移影響很小\n\n');

%% 6. 四種設計的完整比較（教材 Table 8-3）
fprintf('=== 6. 設計方法比較（Table 8-3）===\n');
Dz_ll  = 5.227*tf(conv([1 -0.9982],[1 -0.9792]), conv([1 -0.9993],[1 -0.8604]), T);
Dz_pid = 28.52*tf(conv([1 -0.99986],[1 -0.9504]), conv([1 0],[1 -1]), T);
names  = {'8.1 落後', '8.2 超前', '8.3 落後-超前', '8.4 PI', '8.5 PID'};
Ds     = {Dz_lag, Dz_lead, Dz_ll, Dz_pi, Dz_pid};
bookGM = [16.8 12.4 11.2 16.0 23.3];
bookTr = [3.15 1.05 1.05 2.95 1.05];
bookOS = [14.1 11.4 10.7 13.8 13.0];

fprintf('  %-15s %-9s %-9s %-9s %-9s %s\n', '設計', 'GM(dB)', '教材GM', '上升(s)', '教材', '超越(%)');
figure('Name', '6. 四種設計的階躍響應比較', 'Position', [60 60 900 480]);
cols = {'b','r','g','m','k'};
for i = 1:numel(Ds)
    L    = Ds{i}*Gz;
    Tcl  = feedback(L, 1);
    [gm, pm] = my_margin(L, T);
    [y, t]   = step(Tcl, 0:T:40);
    yf   = y(end);
    i10  = find(y >= 0.1*yf, 1);  i90 = find(y >= 0.9*yf, 1);
    tr   = t(i90) - t(i10);
    os   = (max(y) - yf)/yf*100;
    fprintf('  %-15s %-9.1f %-9.1f %-9.2f %-9.2f %.1f (教材 %.1f)\n', ...
            names{i}, gm, bookGM(i), tr, bookTr(i), os, bookOS(i));
    stairs(t, y, cols{i}, 'LineWidth', 1.6); hold on;
end
plot([0 40], [1 1], 'k:', 'LineWidth', 1);
grid on; xlim([0 20]);
title('Table 8-3：五種數位控制器設計的單位階躍響應');
xlabel('時間 t (秒)'); ylabel('c(kT)');
legend([names, {'目標值 1'}], 'Location', 'southeast');

fprintf('\n  【本章最重要的結論】\n');
fprintf('    落後      -> 穩定裕度好，但頻寬低、反應慢（安定 32.4 s）\n');
fprintf('    超前      -> 反應快（上升 1.05 s），但斜坡誤差沒改善\n');
fprintf('    落後-超前 -> 兩者兼得，斜坡誤差降到 0.5\n');
fprintf('    PI        -> 斜坡誤差 0，但頻寬低\n');
fprintf('    PID       -> 全面最佳（= 落後的積分 + 超前的微分）\n');

disp(' ');
disp('六個實驗全部完成，共產生 1 張圖。');

%% ===== 輔助函數（Octave 需定義在使用前，故本檔以 function 檔尾方式提供）=====
% 註：本檔在 Octave 執行時，下列函數需放在檔尾；MATLAB 亦同。

function Dz = w2z_filter(a0, ww0, wwp, T)
    % 式 (8-14)、(8-15)：把 w 平面的一階補償器轉成 D(z)
    Kd = a0*(wwp*(ww0 + 2/T))/(ww0*(wwp + 2/T));
    z0 = (2/T - ww0)/(2/T + ww0);
    zp = (2/T - wwp)/(2/T + wwp);
    Dz = Kd*tf([1 -z0], [1 -zp], T);
end

function [gm_db, pm_deg] = my_margin(L, T)
    % 自己掃頻算增益／相位裕度。
    % 原因：Octave 的 margin 對本章補償後的系統常回傳 pm=180、wp=NaN。
    [nL, dL] = tfdata(L, 'v');
    wv = logspace(-4, log10(pi/T), 300000);
    Lv = polyval(nL, exp(1j*wv*T)) ./ polyval(dL, exp(1j*wv*T));
    mag = abs(Lv);  ph = unwrap(angle(Lv))*180/pi;
    i = find(mag(1:end-1) >= 1 & mag(2:end) < 1, 1);      % 增益交越
    j = find(ph(1:end-1) >= -180 & ph(2:end) < -180, 1);  % 相位交越
    if isempty(i), pm_deg = NaN; else pm_deg = 180 + ph(i); end
    if isempty(j), gm_db = Inf;  else gm_db = -20*log10(mag(j)); end
end
