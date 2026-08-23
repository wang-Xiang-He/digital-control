%% Chapter 7：穩定度分析技巧 (Stability Analysis Techniques)
% 對應教材 chp7.md。本檔案為「乾淨、可直接執行版」；
% 完整教學說明（符號定義、公式推導、MATLAB 語法解說）請見 chp7.ipynb。
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

%% 1. 雙線性轉換與 Routh-Hurwitz（教材例 7.2，T = 0.1 s）
% 受控體 Gp(s) = 1/(s(s+1))，加可調增益 K
T1  = 0.1;
Gz1 = tf([0.00484 0.00468], [1 -1.905 0.905], T1);
Gw1 = d2c(Gz1, 'tustin');          % 'tustin' 就是雙線性轉換 z=(1+(T/2)w)/(1-(T/2)w)
[nw1, dw1] = tfdata(Gw1, 'v');

fprintf('=== 1. 雙線性轉換（例 7.2，T = %g s）===\n', T1);
fprintf('  G(w) 分子 = [%.4e  %.5f  %.4f]\n', nw1);
fprintf('  G(w) 分母 = [%g  %.4f  %.3e]\n', dw1);
fprintf('  教材 (-4.199e-05 w^2 - 0.04913 w + 0.9995)/(w^2 + 0.9974 w + ~0)\n');
% 特徵方程式 1+K*G(w)=0 -> (1-0.000042K)w^2 + (0.997-0.0491K)w + K = 0
% Routh 陣列的 w^1 列給出最嚴格的條件
fprintf('  Routh w^1 列：0.997 - 0.0491K > 0  ->  K < %.1f  （教材 20.3）\n\n', 0.997/0.0491);

%% 2. 取樣週期對穩定度的影響（教材例 7.3，T = 1 s）
T2  = 1;
Gz2 = tf([0.368 0.264], [1 -1.368 0.368], T2);
Gw2 = d2c(Gz2, 'tustin');
[nw2, dw2] = tfdata(Gw2, 'v');

fprintf('=== 2. 取樣週期的影響（例 7.3，T = %g s）===\n', T2);
fprintf('  G(w) 分子 = [%.5f  %.4f  %.4f]   教材 [-0.03801 -0.386 0.924]\n', nw2);
fprintf('  G(w) 分母 = [%g  %.4f  %.3e]     教材 [1 0.924 ~0]\n', dw2);
fprintf('  Routh w^1 列：0.924 - 0.386K > 0  ->  K < %.3f  （教材 2.39）\n\n', 0.924/0.386);

fprintf('  【本節最重要的結論】\n');
fprintf('    T = %.1f s  ->  0 < K < %.1f\n', T1, 0.997/0.0491);
fprintf('    T = %.1f s  ->  0 < K < %.2f\n', T2, 0.924/0.386);
fprintf('    T 變大 10 倍，可用增益縮小約 %.1f 倍\n', (0.997/0.0491)/(0.924/0.386));
fprintf('    原因：取樣器與資料保持器引入相位落後（第 3 章 ZOH 等效 T/2 延遲）\n\n');

%% 3. Jury 穩定度檢定（教材例 7.4）
% 特徵方程式：z^2 + (0.368K - 1.368)z + (0.368 + 0.264K) = 0
fprintf('=== 3. Jury 穩定度檢定（例 7.4）===\n');
fprintf('  特徵方程式：z^2 + (0.368K-1.368)z + (0.368+0.264K) = 0\n');
fprintf('  二階系統只有 n+1 = 3 個條件，而且都不必建陣列：\n');
fprintf('    Q(1) > 0        : 0.632K > 0            ->  K > 0\n');
fprintf('    (-1)^2 Q(-1) > 0: 2.736 - 0.104K > 0    ->  K < %.1f\n', 2.736/0.104);
fprintf('    |a0| < a2       : 0.368 + 0.264K < 1    ->  K < %.2f  <- 最嚴格\n', 0.632/0.264);
Kc = 0.632/0.264;
fprintf('  => 穩定範圍 0 < K < %.2f，與 Routh-Hurwitz 完全一致\n\n', Kc);

% 用程式逐一驗證三個條件
fprintf('  數值驗證（掃描 K，找實際的臨界值）：\n');
fprintf('    K        最大 |極點|   穩定?\n');
for Kx = [1 2 2.39 2.4 3]
    p = roots([1, 0.368*Kx-1.368, 0.368+0.264*Kx]);
    fprintf('    %-8.2f %-13.6f %s\n', Kx, max(abs(p)), ...
            merge(max(abs(p)) < 1, '是', '否'));
end
fprintf('\n');

%% 4. 由臨界增益求振盪頻率（教材例 7.3、7.4）
fprintf('=== 4. 振盪頻率（例 7.3、7.4）===\n');
% 方法一：z 平面 —— 臨界增益下的特徵方程式根
p = roots([1, 0.368*Kc-1.368, 0.368+0.264*Kc]);
fprintf('  [z 平面] K = %.2f 時特徵方程式的根：\n', Kc);
fprintf('    z = %.3f +- j%.3f，|z| = %.4f（應為 1），角度 = %.1f deg = %.4f rad\n', ...
        real(p(1)), abs(imag(p(1))), abs(p(1)), abs(angle(p(1)))*180/pi, abs(angle(p(1))));
fprintf('    教材 0.244 +- j0.970 = 1 angle 75.9 deg = 1.32 rad\n');
fprintf('    振盪頻率 w = theta/T = %.4f rad/s   教材 1.32\n\n', abs(angle(p(1)))/T2);

% 方法二：w 平面 —— Routh 陣列的輔助方程式
ww = sqrt(0.924*Kc/(1 - 0.03801*Kc));
fprintf('  [w 平面] 輔助方程式 (1-0.03801K)w^2 + 0.924K = 0\n');
fprintf('    w_w = %.4f   教材 1.5585\n', ww);
fprintf('    由式 (7-10) 反解 w = (2/T)atan(w_w*T/2) = %.4f rad/s   教材 1.324\n', ...
        (2/T2)*atan(ww*T2/2));
fprintf('  => 兩種方法結果一致\n\n');

%% 5. 根軌跡（教材例 7.7）
fprintf('=== 5. 根軌跡（例 7.7）===\n');
fprintf('  KG(z) = 0.368K(z + 0.717)/((z-1)(z-0.368))\n');
[nz2, dz2] = tfdata(Gz2, 'v');
fprintf('  零點 z = %.4f  （教材 -0.717）\n', roots(nz2));
fprintf('  極點 z = %.4f, %.4f  （教材 1 與 0.368）\n', roots(dz2));

% 分離點：d/dz[G(z)] = 0。用 den*num' - num*den' = 0（規則 6 的等價形式）
% num = 0.368z + 0.264，den = z^2 - 1.368z + 0.368
nb = [0.368 0.264]; db = [1 -1.368 0.368];
brk = roots(conv(db, polyder(nb)) - conv(nb, polyder(db)));
brk = sort(real(brk(abs(imag(brk)) < 1e-9)));
fprintf('  分離點（解 den*num'' - num*den'' = 0）：');
fprintf('%.4f  ', brk); fprintf('  教材 0.65 與 -2.08\n');
for b = brk'
    Kb = -1/(polyval(nb,b)/polyval(db,b));
    fprintf('    z = %8.4f  ->  K = %.4f\n', b, Kb);
end
fprintf('  教材：z=0.65 時 K=0.196；z=-2.08 時 K=15.0\n\n');

figure('Name', '5. 根軌跡（例 7.7）');
rlocus(Gz2); hold on;
th = linspace(0, 2*pi, 300);
plot(cos(th), sin(th), 'k--', 'LineWidth', 1.2);   % 單位圓 = 穩定邊界
plot(real(p), imag(p), 'rp', 'MarkerSize', 14, 'MarkerFaceColor', 'r');
axis([-3 2 -2 2]); axis equal; grid on;
title('根軌跡（例 7.7），紅星為 K=2.39 穿越單位圓處');
xlabel('Re(z)'); ylabel('Im(z)');

%% 6. Nyquist 圖（教材例 7.10）
fprintf('=== 6. Nyquist 圖（例 7.10）===\n');
wv = logspace(-3, log10(pi/T2), 40000);
Lv = polyval(nz2, exp(1j*wv*T2)) ./ polyval(dz2, exp(1j*wv*T2));
re = real(Lv); im = imag(Lv);
idx = find(im(1:end-1).*im(2:end) < 0);
% 另一個交點在頻率上限 w = pi/T，也就是 z = exp(j*pi) = -1（Nyquist 頻率，端點）
G_at_minus1 = polyval(nz2, -1) / polyval(dz2, -1);
fprintf('  穿越實軸的交點：');
fprintf('%.4f  ', re(idx)); fprintf('\n');
fprintf('  端點 w = pi/T（z = -1）處：G(-1) = %.4f\n', G_at_minus1);
fprintf('  教材 -0.0381 與 -0.418  => 兩者都對上了\n');
fprintf('  （-0.0381 那個不是「穿越」而是曲線的端點，靠掃頻找不到，要直接代 z = -1）\n');
xc = min([re(idx), G_at_minus1]);        % 最負的交點
fprintf('  由最負交點 %.4f 推得臨界增益 = 1/|%.4f| = %.3f   教材 2.39\n', xc, xc, 1/abs(xc));
fprintf('  判別：N = 0（不包圍 -1 點），P = 0  =>  Z = N+P = 0，系統穩定\n\n');

figure('Name', '6. Nyquist 圖（例 7.10）');
plot(re, im, 'b-', 'LineWidth', 1.5); hold on;
plot(re, -im, 'b-', 'LineWidth', 1.5);
plot(-1, 0, 'r+', 'MarkerSize', 14, 'LineWidth', 2);
grid on; axis([-1.2 0.2 -0.7 0.7]);
title('Nyquist 圖（例 7.10），紅十字為 -1 點');
xlabel('Re'); ylabel('Im');

%% 7. Bode 圖與增益／相位裕度（教材例 7.12）
fprintf('=== 7. Bode 圖與裕度（例 7.12）===\n');
Gw_ex = tf([-0.0381 -0.386 0.924], [1 0.924 0]);
fprintf('  G(w) 零點 = %.3f, %.3f   教材 (w-2)(w+12.14) -> 2 與 -12.14\n', sort(roots([-0.0381 -0.386 0.924])));
fprintf('  G(w) 極點 = %.3f, %.3f   教材 w(w+0.924) -> 0 與 -0.924\n', sort(roots([1 0.924 0])));
fprintf('  轉折頻率：0, 0.924, 2, 12.14\n\n');

[gm_z, pm_z] = margin(Gz2);
[gm_w, pm_w] = margin(Gw_ex);
fprintf('  由 G(z) 算：GM = %.4f 倍 = %.2f dB，PM = %.2f deg\n', gm_z, 20*log10(gm_z), pm_z);
fprintf('  由 G(w) 算：GM = %.4f 倍 = %.2f dB，PM = %.2f deg\n', gm_w, 20*log10(gm_w), pm_w);
fprintf('  兩者相同（同一個系統的兩種表示）\n');
fprintf('  增益裕度 %.3f 倍，正好就是臨界增益 K = 2.39\n\n', gm_z);

figure('Name', '7. Bode 圖（例 7.12）');
bode(Gw_ex); grid on;
title('Bode 圖：G(w)（例 7.12）');

%% 附錄：兩個 Octave 陷阱（實測，MATLAB 未必相同）
fprintf('=== 附錄：Octave 陷阱 ===\n');
% 陷阱 1：bode 對含 z=1 極點的離散系統，相位是錯的
Tp = 0.05;
Gp_ex8 = c2d(tf([2],[1 3 2 0]), Tp, 'zoh');    % 第 8 章的受控體，含積分器
[np, dp] = tfdata(Gp_ex8, 'v');
fprintf('  陷阱1：bode 對「含 z=1 極點」的離散系統，相位錯誤\n');
fprintf('    w       bode 相位    freqresp 相位   教材 Table 8-1\n');
book = [-98.7 -120.5 -163.0];
i = 1;
for w = [0.1 0.36 1.0]
    [~, pb] = bode(Gp_ex8, w);
    H = freqresp(Gp_ex8, w);
    fprintf('    %-7.2f %-12.2f %-15.2f %.1f\n', w, pb, angle(H)*180/pi, book(i));
    i = i + 1;
end
fprintf('    => 取相位一律用 freqresp，不要用 bode 的第二個回傳值\n\n');

% 陷阱 2：exist 看不到 LTI 方法
fprintf('  陷阱2：exist 判斷不了 LTI 類別的「方法」\n');
for f = {'d2c', 'c2d', 'margin', 'nyquist'}
    fprintf('    exist(''%s'') = %d，但實際可以呼叫\n', f{1}, exist(f{1}));
end
fprintf('    => 不要用 exist 判斷 c2d/d2c/margin/nyquist 是否可用\n');

disp(' ');
disp('七個實驗全部完成，共產生 3 張圖。');
