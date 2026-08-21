% 數位控制系統第一章：五個系統獨立視窗與疊加圖 (完整修復版)
clear; clc;
% 若在 Octave 環境，請取消下方註解：
pkg load control;
graphics_toolkit("qt");

% 設定字體以解決 Windows 下的中文亂碼問題
set(0, 'DefaultTextFontName', 'Microsoft JhengHei');
set(0, 'DefaultAxesFontName', 'Microsoft JhengHei');

%% 1. 建立衛星系統模型
J = 0.6;
Gp_sat = tf([1], [J 0 0]);

%% 2. 建立直流伺服馬達系統模型
Ra = 2; Kb = 0.1; KT = 0.1; Jm = 0.05; Bm = 0.01;
A22 = -(Bm * Ra + KT * Kb) / (Jm * Ra);
B2 = KT / (Jm * Ra);
sys_motor = ss([0 1; 0 A22], [0; B2], [1 0], 0);

%% 3. SMIB 電力系統模型
M = 0.5; d = 0.1; k = 10;
Gp_smib = tf([k], [M d k]);

%% 4. 溫控系統模型
C_thermal = 100; R_thermal = 2; VH = 0.5;
tau = C_thermal / (VH + 1/R_thermal); 
Gain = 1 / (VH + 1/R_thermal);
Gp_temp = tf([Gain], [tau 1]);

%% === 開始繪圖 (五個獨立視窗 + 一個疊加視窗) ===

% 1. 衛星系統
figure(1);
step(Gp_sat, 'r');
title('1. 衛星系統 (紅) - 自然發展');
grid on;

% 2. 馬達系統
figure(2);
step(sys_motor, 'g');
title('2. 直流馬達 (綠) - 自然發展');
grid on;

% 3. SMIB 發電機
figure(3);
step(Gp_smib, 'b');
title('3. SMIB發電機 (藍) - 自然發展');
grid on;

% 4. 溫控水槽
figure(4);
step(Gp_temp, 'm');
title('4. 溫控水槽 (紫) - 自然發展');
grid on;

% 5. 四系統疊加圖
figure(5);
t = 0:0.1:50; % 強制統一時間軸
[y_sat, t_sat] = step(Gp_sat, t);
[y_motor, t_motor] = step(sys_motor, t);
[y_smib, t_smib] = step(Gp_smib, t);
[y_temp, t_temp] = step(Gp_temp, t);

plot(t_sat, y_sat, 'r', 'LineWidth', 1.5); hold on;
plot(t_motor, y_motor, 'g', 'LineWidth', 1.5);
plot(t_smib, y_smib, 'b', 'LineWidth', 1.5);
plot(t_temp, y_temp, 'm', 'LineWidth', 1.5);
grid on;
title('5. 四系統階躍響應疊加圖 (前 50 秒)');
xlabel('時間 (sec)');
ylabel('系統輸出');
legend('衛星', '馬達', '發電機', '水槽', 'Location', 'northwest');

disp('✅ 五個獨立視窗與一張疊加圖已成功生成！');