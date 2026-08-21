%% Chapter 1：數位控制系統 - 四系統建模與階躍響應比較
% 對應教材 chp1.md。本檔案為「乾淨、可直接執行版」；
% 完整教學說明（符號定義、公式推導、MATLAB 語法解說）請見 chp1.ipynb。
clear; clc;

% 若在 Octave 環境執行，請取消下方兩行的註解：
% pkg load control;
% graphics_toolkit('qt');

% 設定字體以避免 Windows 下的中文亂碼
set(0, 'DefaultTextFontName', 'Microsoft JhengHei');
set(0, 'DefaultAxesFontName', 'Microsoft JhengHei');

%% 1. 衛星系統 (Satellite) — 無阻尼二階積分系統
% Gp(s) = 1 / (J*s^2)
J = 0.6;                          % 轉動慣量 (kg·m^2)
Gp_sat = tf([1], [J 0 0]);

%% 2. 直流伺服馬達 (DC Servo Motor) — 帶阻尼的一階積分系統
Ra = 2;      % 電樞電阻 (Ω)
Kb = 0.1;    % 反電動勢常數 (V·s/rad)
KT = 0.1;    % 轉矩常數 (N·m/A)
Jm = 0.05;   % 馬達轉動慣量 (kg·m^2)
Bm = 0.01;   % 黏滯摩擦係數 (N·m·s/rad)
A22 = -(Bm * Ra + KT * Kb) / (Jm * Ra);
B2  = KT / (Jm * Ra);
sys_motor = ss([0 1; 0 A22], [0; B2], [1 0], 0);

%% 3. SMIB 電力系統 (同步發電機小信號模型) — 穩定二階系統
M = 0.5;   % 角動量
d = 0.1;   % 阻尼係數
k = 10;    % 同步功率係數
Gp_smib = tf([k], [M d k]);

%% 4. 溫控艙系統 (Temperature Control) — 一階滯後系統
C_t = 100;   % 熱容 C (J/°C)
R_t = 2;     % 熱阻 R (°C/W)
VH  = 0.5;   % 流率 V x 單位體積熱容 H
tau  = C_t / (VH + 1/R_t);
Gain = 1 / (VH + 1/R_t);
Gp_temp = tf([Gain], [tau 1]);

%% === 繪圖：四個獨立視窗 + 一張疊加比較圖 ===

% 1. 衛星系統
figure(1);
step(Gp_sat, 'r');
title('1. 衛星系統 (紅) - 拋物線發散（不穩定）');
grid on;

% 2. 馬達系統
figure(2);
step(sys_motor, 'g');
title('2. 直流馬達 (綠) - 角度持續等速增加');
grid on;

% 3. SMIB 發電機
figure(3);
step(Gp_smib, 'b');
title('3. SMIB 發電機 (藍) - 震盪後穩定');
grid on;
disp('=== SMIB 極點（確認穩定性，實部應皆 < 0）===');
pole(Gp_smib)

% 4. 溫控水槽
figure(4);
step(Gp_temp, 'm');
title('4. 溫控水槽 (紫) - 慢速平滑爬坡');
grid on;

% 5. 四系統疊加比較圖
figure('Name', '四系統疊加比較圖', 'Position', [100, 100, 1000, 600]);
t = 0:0.1:50; % 統一時間軸，觀察前 50 秒

[y_sat, t_sat]     = step(Gp_sat, t);
[y_motor, t_motor] = step(sys_motor, t);
[y_smib, t_smib]   = step(Gp_smib, t);
[y_temp, t_temp]   = step(Gp_temp, t);

plot(t_sat, y_sat, 'r', 'LineWidth', 1.5); hold on;
plot(t_motor, y_motor, 'g', 'LineWidth', 1.5);
plot(t_smib, y_smib, 'b', 'LineWidth', 1.5);
plot(t_temp, y_temp, 'm', 'LineWidth', 1.5);
grid on;

title('四個系統的階躍響應疊加圖 (觀察前 50 秒)');
xlabel('時間 (sec)');
ylabel('系統輸出');
legend('1. 衛星 (紅) - 拋物線失控', ...
       '2. 馬達 (綠) - 直線失控', ...
       '3. 發電機 (藍) - 震盪後穩定', ...
       '4. 溫控水槽 (紫) - 慢速平滑爬坡', ...
       'Location', 'northwest');

%% 6. 標準負回授迴路示範：對 SMIB 系統加上比例控制器 C(s)=Kc
% 對應 chp1.md 第三節「標準負回授迴路的轉移函數」與 Fig. 1-13
Kc = 2;                                % 比例控制器增益
Gc = tf(Kc, 1);                        % 建立控制器 C(s) = Kc
sys_closed = feedback(Gc*Gp_smib, 1);  % 負回授：C(s)Gp(s) / (1+C(s)Gp(s))

figure('Name', 'SMIB 開迴路 vs 閉迴路比較');
step(Gp_smib, 'b--', sys_closed, 'k', 10);
legend('開迴路 G_p(s)', ['閉迴路 (K_c=' num2str(Kc) ')'], 'Location', 'southeast');
title('負回授控制對 SMIB 暫態響應的影響');
grid on;

disp('六張圖已成功生成！');
