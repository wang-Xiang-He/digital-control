%% Chapter 4：開迴路離散時間系統 (Open-Loop Discrete-Time Systems)
% 對應教材 chp4.md。本檔案為「乾淨、可直接執行版」；
% 完整教學說明（符號定義、公式推導、MATLAB 語法解說）請見 chp4.ipynb。
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

T = 0.1;                       % 取樣週期 (s)
fprintf('取樣週期 T = %g s\n\n', T);

%% 1. 脈衝轉移函數（教材例 4.2、4.3）
% Gp(s) = 1/(s+1)；G(z) = Z[(1-e^{-Ts})/s * Gp(s)] = (1-e^{-T})/(z-e^{-T})
% c2d 的 'zoh' 就是在乘上那個 (1-e^{-Ts})/s
Gp = tf(1, [1 1]);             % 分子 [1]，分母 1*s+1 -> [1 1]
Gz = c2d(Gp, T, 'zoh');
[nz, dz] = tfdata(Gz, 'v');

fprintf('=== 1. 脈衝轉移函數（例 4.2、4.3）===\n');
fprintf('  c2d 給的 G(z) = (%.6f z + %.6f) / (z %+.6f)\n', nz(1), nz(2), dz(2));
fprintf('  教材公式      = %.6f / (z - %.6f)\n', 1-exp(-T), exp(-T));
fprintf('  分子常數項差異 = %.2e，分母差異 = %.2e\n', ...
        abs(nz(2)-(1-exp(-T))), abs(dz(2)+exp(-T)));

% 階躍響應與教材 c(kT) = 1 - e^{-kT} 比對
n = 0:8;
[y1, ~] = step(Gz, 0:T:8*T);
c1_theory = 1 - exp(-n*T);
fprintf('  n     模擬 c(nT)    教材 1-e^{-nT}   差\n');
for k = 1:numel(n)
    fprintf('  %-5d %-13.6f %-16.6f %.2e\n', n(k), y1(k), c1_theory(k), abs(y1(k)-c1_theory(k)));
end
fprintf('\n');

%% 2. 直流增益檢查（教材式 4-14）
% dc gain = lim_{z->1} G(z) = lim_{s->0} Gp(s)
fprintf('=== 2. 直流增益檢查（式 4-14）===\n');
fprintf('  G(1)            = %.8f   （手動代 z=1）\n', polyval(nz,1)/polyval(dz,1));
fprintf('  dcgain(Gz)      = %.8f   （離散系統代 z=1）\n', dcgain(Gz));
fprintf('  lim Gp(s), s->0 = %.8f   （連續系統代 s=0）\n', dcgain(Gp));
fprintf('  => 三者相同，G(z) 的計算正確\n\n');

%% 3. G1G2(z) 不等於 G1(z)*G2(z)（教材式 4-19）
% 組態(a)：兩受控體之間「有」取樣器 -> C(z) = G1(z)*G2(z)*E(z)
% 組態(b)：兩受控體之間「沒有」取樣器 -> C(z) = G1G2bar(z)*E(z)
G1s = tf(1, [1 1]);            % G1(s) = 1/(s+1)
G2s = tf(1, [1 2]);            % G2(s) = 1/(s+2)

G1z = c2d(G1s, T, 'zoh');      % 各自前面都有保持器
G2z = c2d(G2s, T, 'zoh');
prod_sep = G1z * G2z;          % 組態(a)：G1(z)*G2(z)
G12bar   = c2d(G1s*G2s, T, 'zoh');   % 組態(b)：先在 s 域相乘再離散化

fprintf('=== 3. G1G2(z) vs G1(z)*G2(z)（式 4-19）===\n');
fprintf('  兩者的 dcgain：%.6f  vs  %.6f  （穩態相同）\n', ...
        dcgain(prod_sep), dcgain(G12bar));
[ya, ~] = step(prod_sep, 0:T:6*T);
[yb, ~] = step(G12bar,   0:T:6*T);
fprintf('  但暫態完全不同：\n');
fprintf('  n     組態(a) G1(z)G2(z)   組態(b) G1G2bar(z)   差\n');
for k = 1:7
    fprintf('  %-5d %-21.6f %-21.6f %.6f\n', k-1, ya(k), yb(k), abs(ya(k)-yb(k)));
end
fprintf('  => 中間多一個取樣器加保持器，是「物理上不同的系統」\n\n');

figure('Name', '3. G1G2(z) 不等於 G1(z)G2(z)');
stairs(0:T:6*T, ya, 'b-', 'LineWidth', 2); hold on;
stairs(0:T:6*T, yb, 'r--', 'LineWidth', 2); grid on;
title('式 4-19：中間有無取樣器，響應完全不同');
xlabel('時間 t (秒)'); ylabel('c(kT)');
legend('組態(a)：G_1(z)G_2(z)（中間有取樣器）', ...
       '組態(b)：G_1G_2(z)（中間無取樣器）', 'Location', 'southeast');

%% 4. 含數位濾波器的開迴路系統（教材例 4.4）
% D(z) = 2 - z^{-1} = (2z-1)/z，來自差分方程式 m(kT) = 2e(kT) - e[(k-1)T]
Dz = tf([2 -1], [1 0], T);     % 分子 2z-1 -> [2 -1]；分母 z -> [1 0]
Cz = Dz * Gz;                  % C(z) = D(z)G(z)

fprintf('=== 4. 含數位濾波器（例 4.4）===\n');
[y4, ~] = step(Cz, 0:T:6*T);
n4 = 0:6;
c4_theory = 1 + (exp(T)-2)*exp(-n4*T);   % 教材：c(nT)=1+(e^T-2)e^{-nT}, n>=1
c4_theory(1) = 0;                         % 教材：c(0)=0
fprintf('  n     模擬 c(nT)    教材公式        差\n');
for k = 1:numel(n4)
    fprintf('  %-5d %-13.6f %-15.6f %.2e\n', n4(k), y4(k), c4_theory(k), abs(y4(k)-c4_theory(k)));
end
fprintf('  終值定理 lim c(nT)          = %.6f （教材為 1）\n', dcgain(Cz));
fprintf('  式(4-14) dc = D(1)*Gp(0)    = %g * %g = %g\n', ...
        dcgain(Dz), dcgain(Gp), dcgain(Dz)*dcgain(Gp));
fprintf('  => 三種驗證方式（終值定理／增益相乘／模擬）結果一致\n\n');

%% 5. 修正 z 轉換與時間延遲（教材例 4.8）
% t0 = 0.4T，因此 k=0、Delta=0.4、m=1-Delta=0.6
% C(z) = [z(1-e^{-mT}) + e^{-mT} - e^{-T}] / [(z-1)(z-e^{-T})]
mT  = 0.6*T;
num5 = [1-exp(-mT), exp(-mT)-exp(-T)];      % 正次冪 z 的係數
den5 = conv([1 -1], [1 -exp(-T)]);          % (z-1)(z-e^{-T})

fprintf('=== 5. 修正 z 轉換與時間延遲（例 4.8，t0 = 0.4T）===\n');
fprintf('  C(z) 分子 = [%.6f  %.6f]\n', num5);
fprintf('  C(z) 分母 = [%.6f  %.6f  %.6f]\n', den5);

% 反 z 轉換：filter 把係數當成 z^{-1} 次冪，分子要先補零對齊分母次數
num5_pad = [0, num5];
N5 = 7;
c5 = filter(num5_pad, den5, [1, zeros(1, N5-1)]);
fprintf('  n     反z轉換 c(nT)   教材 1-e^{-(n-0.4)T}   差\n');
for k = 1:N5
    nn = k-1;
    if nn == 0, th = 0; else th = 1 - exp(-(nn-0.4)*T); end
    fprintf('  %-5d %-16.6f %-22.6f %.2e\n', nn, c5(k), th, abs(c5(k)-th));
end
fprintf('  => 與「把無延遲響應整體延後 0.4T」的結果完全吻合\n\n');

figure('Name', '5. 時間延遲的效果');
stairs(0:T:6*T, y1(1:7), 'b-', 'LineWidth', 2); hold on;
stairs(0:T:6*T, c5, 'r--', 'LineWidth', 2); grid on;
title('例 4.8：理想時間延遲 t_0 = 0.4T 的效果');
xlabel('時間 t (秒)'); ylabel('c(kT)');
legend('無延遲（例 4.3）', '延遲 0.4T（例 4.8）', 'Location', 'southeast');

%% 6. 離散狀態方程式與脈衝轉移函數（教材例 4.13、4.14）
% Gp(s) = 10/(s(s+1))，連續狀態模型如下
Ac = [0 1; 0 -1];
Bc = [0; 10];
Cc = [1 0];
Dc = 0;

% --- 教材例 4.14 的原始程式在現行 Octave/MATLAB 已無法執行 ---
%   [A,B] = c2d(Ac,Bc,T)          <- 舊版語法，現行 c2d 只吃 LTI 物件
%   [numz,denz] = ss2tf(A,B,C,D)  <- Octave 的 control 套件沒有 ss2tf
% --- 以下為數學內容相同的修正版 ---
sys_c = ss(Ac, Bc, Cc, Dc);        % 步驟 1：打包成 LTI 物件
Gp2   = tf(sys_c);                 % 步驟 2：類比轉移函數（式 4-76）
sys_d = c2d(sys_c, T, 'zoh');      % 步驟 3：離散化（式 4-69、4-71）
[A, B, C, D] = ssdata(sys_d);
Gz2   = tf(sys_d);                 % 步驟 4：脈衝轉移函數（式 4-78）

fprintf('=== 6. 離散狀態方程式（例 4.13、4.14）===\n');
fprintf('  離散 A =\n'); disp(A);
fprintf('  離散 B =\n'); disp(B);
fprintf('  教材例 4.13：A = [1 0.0952; 0 0.905]，B = [0.0484; 0.952]\n');
fprintf('  C = [%g %g]（= Cc，未改變），D = %g（= Dc，未改變）\n', C, D);
[n6, d6] = tfdata(Gz2, 'v');
fprintf('  脈衝轉移函數 G(z) 分子 = [%.6g %.6g %.6g]\n', n6);
fprintf('                    分母 = [%.6g %.6g %.6g]\n', d6);
fprintf('  dc 檢查：G(z) 在 z=1 -> %.4g；Gp(s) 在 s=0 -> %.4g\n', dcgain(Gz2), dcgain(Gp2));
fprintf('  說明：本例 Gp(s)=10/(s(s+1)) 含純積分器，理論 dc 增益為無限大。\n');
fprintf('        連續側直接回傳 Inf；離散側因為極點 z=1 落在浮點誤差內，\n');
fprintf('        得到一個極大的有限值而非 Inf——這是數值計算的正常現象。\n\n');

%% 7. 級數展開法 vs c2d（教材式 4-72、4-74）
% Phi_c(T) = I + Ac*T + Ac^2*T^2/2! + ...
% B        = (I*T + Ac*T^2/2! + Ac^2*T^3/3! + ...) * Bc
fprintf('=== 7. 級數展開法需要幾項才夠準（式 4-72、4-74）===\n');
fprintf('  項數   max|A_series - A_c2d|   max|B_series - B_c2d|\n');
for nterms = 1:6
    Phi = zeros(2); Int = zeros(2);
    for k = 0:nterms-1
        Phi = Phi + (Ac^k) * T^k / factorial(k);            % 式 (4-72)
        Int = Int + (Ac^k) * T^(k+1) / factorial(k+1);      % 式 (4-73)
    end
    Bs = Int * Bc;                                          % 式 (4-74)
    fprintf('  %-6d %-23.2e %.2e\n', nterms, max(max(abs(Phi-A))), max(abs(Bs-B)));
end
fprintf('  => 教材說「三位有效數字需 3 項、六位有效數字需 5 項」，與上表吻合\n');
fprintf('  注意：Ac^k 是「矩陣次方」，若寫成 Ac.^k 會逐元素次方，結果完全錯誤\n\n');

disp('七個實驗全部完成，共產生 2 張圖。');
