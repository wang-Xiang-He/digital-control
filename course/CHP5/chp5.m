%% Chapter 5：閉迴路系統 (Closed-Loop Systems)
% 對應教材 chp5.md。本檔案為「乾淨、可直接執行版」；
% 完整教學說明（符號定義、公式推導、MATLAB 語法解說）請見 chp5.ipynb。
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

%% 1. 標準閉迴路輸出函數（教材式 5-11）
% C(z)/R(z) = G(z) / (1 + GH(z))；單位回授時 H=1
Gp = tf(1, [1 1]);             % 受控體 Gp(s) = 1/(s+1)
Gz = c2d(Gp, T, 'zoh');        % G(z)，含零階保持器
Tz = feedback(Gz, 1);          % 單位負回授：G(z)/(1+G(z))

fprintf('=== 1. 標準閉迴路（式 5-11，單位回授）===\n');
[ng, dg] = tfdata(Gz, 'v');
[nt, dt] = tfdata(Tz, 'v');
fprintf('  開迴路 G(z) = %.6f / (z %+.6f)\n', ng(2), dg(2));
fprintf('  閉迴路 T(z) = %.6f / (z %+.6f)\n', nt(2), dt(2));
% 手動驗證 feedback：T(z) = G/(1+G)
Tz_manual = Gz / (1 + Gz);
fprintf('  手動 G/(1+G) 與 feedback 的極點差 = %.2e\n', ...
        max(abs(sort(pole(Tz)) - sort(pole(minreal(Tz_manual))))));
fprintf('  閉迴路 dc 增益 = %.6f\n\n', dcgain(Tz));

%% 2. GH bar(z) 不等於 G(z)H(z)（教材式 5-11 分母的警告）
% 回授路徑上有感測器 H(s) 時，分母是 Z[G(s)H(s)]，不是 Z[G]*Z[H]
Hs = tf(2, [1 5]);             % 感測器 H(s) = 2/(s+5)
GH_bar = c2d(Gp*Hs, T, 'zoh');           % 正確：先在 s 域相乘再離散化
GH_sep = Gz * c2d(Hs, T, 'zoh');         % 錯誤：各自離散化後相乘

fprintf('=== 2. GHbar(z) vs G(z)H(z)（式 5-11 分母的陷阱）===\n');
[n1, d1] = tfdata(GH_bar, 'v');
[n2, d2] = tfdata(GH_sep, 'v');
fprintf('  GHbar(z) 分子 = [%.6g %.6g %.6g]\n', n1);
fprintf('  G(z)H(z) 分子 = [%.6g %.6g %.6g]\n', n2);
fprintf('  兩者 dcgain：%.6f  vs  %.6f\n', dcgain(GH_bar), dcgain(GH_sep));

% 用它們各自組出的閉迴路，比較階躍響應
Tz_ok  = feedback(Gz, c2d(Hs, T, 'zoh'));   % feedback 內部做的是 G/(1+G*H)
fprintf('  注意：feedback(Gz, Hz) 算的是 G(z)/(1+G(z)H(z))，\n');
fprintf('        若實體上感測器與受控體之間「沒有取樣器」，\n');
fprintf('        正確的分母應該是 1+GHbar(z)，必須自己組。\n');
Tz_bar = Gz / (1 + GH_bar);
fprintf('  兩種閉迴路的極點：\n');
fprintf('    用 G(z)H(z)  : ');
pp = sort(pole(Tz_ok)); fprintf('%9.5f%+8.5fj  ', [real(pp)'; imag(pp)']);
fprintf('\n');
fprintf('    用 GHbar(z)  : ');
pp = sort(pole(minreal(Tz_bar))); fprintf('%9.5f%+8.5fj  ', [real(pp)'; imag(pp)']);
fprintf('\n');
fprintf('\n');

%% 3. 含數位控制器的閉迴路（教材例 5.1）
% C(z) = D(z)G(z)R(z) / (1 + D(z)GH(z))；單位回授時 H=1
Dz = tf([0.9 -0.8], [1 -0.9], T);        % D(z) = (0.9z-0.8)/(z-0.9)
Gp3 = tf(10, [1 1 0]);                   % Gp(s) = 10/(s(s+1))
Gz3 = c2d(Gp3, T, 'zoh');
Tz3 = feedback(Dz*Gz3, 1);               % 例 5.1 的標準式

fprintf('=== 3. 含數位控制器的閉迴路（例 5.1）===\n');
[n3, d3] = tfdata(Tz3, 'v');
fprintf('  T(z) 分子 = [%.6g %.6g %.6g %.6g]\n', n3);
fprintf('  T(z) 分母 = [%.6g %.6g %.6g %.6g]\n', d3);
fprintf('    極點 : ');
pp = sort(pole(Tz3)); fprintf('%9.5f%+8.5fj  ', [real(pp)'; imag(pp)']);
fprintf('\n');
fprintf('  絕對值 = '); fprintf('%.5f ', abs(sort(pole(Tz3)))'); fprintf('\n');
fprintf('  全部在單位圓內？ %s（最大絕對值 = %.5f）\n\n', ...
        merge(max(abs(pole(Tz3))) < 1, '是', '否'), max(abs(pole(Tz3))));

%% 4. 關迴路公式（教材式 5-38，例 5.7）
% A = A1 + B1*C1 + (-B2 - B1*D1)*C
% B = B1*D1 + B2
A1 = [1 0.0952 0; 0 0.905 0; 0 0 0.9];   % 受控體(2階) + 濾波器(1階)，尚未關迴路
B1 = [0.0484; 0.952; 0];                 % m(k) 的輸入矩陣
B2 = [0; 0; 1];                          % e(k) 的輸入矩陣
C1 = [0 0 0.01];                         % 濾波器輸出 m = C1*v + D1*e
D1 = 0.9;
C  = [1 0 0];                            % 受控體輸出 y = C*v

A = A1 + B1*C1 + (-B2 - D1*B1)*C;        % 式 (5-38)
B = D1*B1 + B2;

fprintf('=== 4. 關迴路公式（式 5-38，例 5.7）===\n');
fprintf('  閉迴路 A =\n'); disp(A);
fprintf('  閉迴路 B = [%.5f %.5f %.5f]''\n', B);
fprintf('  教材 A = [0.9564 0.0952 0.0005; -0.8568 0.9050 0.0095; -1 0 0.9]\n');
fprintf('  教材 B = [0.0436; 0.8568; 1.0000]\n');
fprintf('  C = [%g %g %g]，D = 0\n\n', C);

%% 5. 兩種方法交叉驗證（教材例 5.7 的兩段程式）
% 教材原始寫法 [num,den]=ss2tf(A,B,C,D,1) 在 Octave 無法執行（沒有 ss2tf）
% 修正版：用 tf(ss(...)) 取代
fprintf('=== 5. 狀態空間法 vs 轉移函數法（例 5.7）===\n');
Tz_ss = tf(ss(A, B, C, 0, T));           % 修正版：取代 ss2tf
[na, da] = tfdata(Tz_ss, 'v');
fprintf('  [狀態空間法] 分子 = [%.6g %.6g %.6g %.6g]\n', na);
fprintf('               分母 = [%.6g %.6g %.6g %.6g]\n', da);
fprintf('  教材 Tz = (0.04356 z^2 + 0.003426 z - 0.03746)/(z^3 - 2.761 z^2 + 2.623 z - 0.852)\n\n');

Tz_tf = feedback(Dz*Gz3, 1);             % 轉移函數法（教材的 Tz_check）
[nb, db] = tfdata(Tz_tf, 'v');
fprintf('  [轉移函數法] 分子 = [%.6g %.6g %.6g %.6g]\n', nb);
fprintf('               分母 = [%.6g %.6g %.6g %.6g]\n', db);
fprintf('  教材 Tz_check = (0.04354 z^2 + 0.00341 z - 0.03743)/(z^3 - 2.761 z^2 + 2.623 z - 0.8518)\n\n');

fprintf('  兩種方法的極點：\n');
fprintf('    狀態空間法 : ');
pp = sort(pole(Tz_ss)); fprintf('%9.5f%+8.5fj  ', [real(pp)'; imag(pp)']);
fprintf('\n');
fprintf('    轉移函數法 : ');
pp = sort(pole(Tz_tf)); fprintf('%9.5f%+8.5fj  ', [real(pp)'; imag(pp)']);
fprintf('\n');
fprintf('\n');

figure('Name', '5. 例 5.7 的兩種方法');
[y1, t1] = step(Tz_ss, 0:T:4);
[y2, ~]  = step(Tz_tf, 0:T:4);
stairs(t1, y1, 'b-', 'LineWidth', 2); hold on;
stairs(t1, y2, 'r--', 'LineWidth', 1.5); grid on;
title('例 5.7：狀態空間法 vs 轉移函數法');
xlabel('時間 t (秒)'); ylabel('y(kT)');
legend('狀態空間法（式 5-38）', '轉移函數法（feedback）', 'Location', 'southeast');

%% 6. 四捨五入誤差的傳播（為什麼兩種方法有微小差異）
% 教材的 A1、B1 是四捨五入到 3~4 位的值；c2d 用的是全精度值
[Ad, Bd] = ssdata(c2d(ss([0 1;0 -1],[0;10],[1 0],0), T, 'zoh'));
fprintf('=== 6. 四捨五入誤差的傳播 ===\n');
fprintf('  教材四捨五入值 : A(1,2)=%.7f  A(2,2)=%.7f  B(1)=%.7f  B(2)=%.7f\n', ...
        0.0952, 0.905, 0.0484, 0.952);
fprintf('  c2d 全精度值   : A(1,2)=%.7f  A(2,2)=%.7f  B(1)=%.7f  B(2)=%.7f\n', ...
        Ad(1,2), Ad(2,2), Bd(1), Bd(2));

% 用全精度值重做式 (5-38)
A1e = [Ad(1,1) Ad(1,2) 0; 0 Ad(2,2) 0; 0 0 0.9];
B1e = [Bd(1); Bd(2); 0];
Ae  = A1e + B1e*C1 + (-B2 - D1*B1e)*C;
Be  = D1*B1e + B2;
Tz_exact = tf(ss(Ae, Be, C, 0, T));
[ne, de] = tfdata(Tz_exact, 'v');
fprintf('\n  用全精度值重做式 (5-38)：\n');
fprintf('    分子 = [%.6g %.6g %.6g %.6g]\n', ne);
fprintf('    分母 = [%.6g %.6g %.6g %.6g]\n', de);
fprintf('  與轉移函數法的差異：\n');
fprintf('    用教材四捨五入值：分子首項差 %.2e\n', abs(na(2)-nb(2)));
fprintf('    用全精度值      ：分子首項差 %.2e\n', abs(ne(2)-nb(2)));
fprintf('  => 差異來自輸入資料的精度，不是方法本身有誤\n');

disp(' ');
disp('六個實驗全部完成，共產生 1 張圖。');
