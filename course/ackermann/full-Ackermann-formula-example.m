% =========================================================================
% 現代控制理論：狀態空間建模與阿克曼公式 (Ackermann's formula) 極點安置實作
% 範例系統：剛體衛星的姿態控制 (Rigid Satellite Attitude Control)
% =========================================================================

% 若在 GNU Octave 執行，需先載入 control 套件 (MATLAB 可刪除此行)
pkg load control;
% 繪圖後端：有 qt 就用 qt，沒有就沿用 fltk 並關閉它的提醒訊息
warning('off', 'Octave:fltk-graphics');
if any(strcmp(available_graphics_toolkits(), 'qt'))
  graphics_toolkit('qt');
end

% 【步驟 1：定義連續時間物理系統參數 (Continuous-Time System)】
% 根據牛頓第二運動定律推導出的物理模型
J = 2;              % 衛星的轉動慣量 (kg-m^2)
Ac = [0 1; 0 0];    % 連續系統矩陣 A_c (無空氣阻力，故右下角為 0)
Bc = [0; 1/J];      % 連續輸入矩陣 B_c (推力器轉矩對角加速度的影響)
Cc = [1 0];         % 連續輸出矩陣 C_c (感測器只能量測到角度 x1)
Dc = 0;             % 直接傳遞矩陣 D_c

sys_c = ss(Ac, Bc, Cc, Dc); % 建立連續時間的狀態空間物件

% 【步驟 2：系統離散化 (Discretization)】
% 電腦是數位計算的，我們必須利用取樣時間 T 將連續的物理世界轉為離散矩陣
T = 0.1;                      % 數位電腦每 0.1 秒運算一次 (取樣週期)
sys_d = c2d(sys_c, T, 'zoh'); % 加上零階保持器 (ZOH) 進行離散化
[A, B, C, D] = ssdata(sys_d); % 萃取出微控制器實際在運算的離散矩陣 A 與 B

% 【步驟 3：向系統「下訂單」(設定期望極點 Desired Poles)】
% 根據我們對衛星阻尼比與反應時間的要求，決定閉迴路系統分母為 0 的位置 (極點)
% 這裡我們直接在 z 平面上指定兩個期望的穩定極點位置
P = [0.8, 0.9]; 

% 【步驟 4：丟進阿克曼公式 (Ackermann's formula)】
% 這是現代控制的核心。電腦會自動建立特徵多項式，並算出能強迫系統符合規格的完美權重。
K = acker(A, B, P);
% 得到的 K 是一個 1x2 的矩陣 [K1, K2]
% K1 是給「角度誤差」的權重；K2 是給「角速度(煞車)」的權重

% 【步驟 5：計算參考輸入增益 N (Reference Gain)】
% 控制律 u(k) = -K*x(k) 會把衛星拉回 0 度。若我們要它轉到特定角度 r，
% 必須計算一個穩態的補償權重 N，確保閉迴路系統的直流增益 (DC Gain) 為 1。
sys_cl = ss(A - B*K, B, C, D, T); % 建立加入狀態回授後的「閉迴路系統」
dc_gain = dcgain(sys_cl);         % 計算閉迴路直流增益
N = 1 / dc_gain;                  % N 即為目標指令的轉換比例

% 【步驟 6：寫回控制系統 (模擬微控制器內部的 while 迴圈)】
steps = 50;                  % 模擬的總步數 (50 步 = 5 秒)
x = [0; 0];                  % 衛星初始狀態：[角度=0; 角速度=0]
r = 30;                      % 目標指令：要求衛星轉向 30 度
y_history = zeros(1, steps); % 建立陣列用來記錄每一步的角度，方便畫圖

for k = 1:steps
    % 1. 軟體控制大腦：計算控制律 (Control Law)
    % 將量測/估測到的狀態乘上阿克曼公式算出的完美增益 K，加上目標指令
    u = -K * x + N * r;
    
    % 2. 物理硬體反應：輸出電壓給硬體，硬體依照 A, B 矩陣的物理慣性走到下一秒
    % 狀態更新方程式：x(k+1) = A*x(k) + B*u(k)
    x_next = A * x + B * u;
    
    % 3. 感測器量測：讀取當下角度 y(k) = C*x(k)
    y = C * x;
    y_history(k) = y; % 記錄當下角度
    
    % 4. 時間推進
    x = x_next;
end

% 【繪製結果】
figure;
stairs(1:steps, y_history, 'LineWidth', 2); % 數位系統習慣用階梯圖(stairs)表示
title('剛體衛星姿態控制 (狀態回授極點安置)', 'fontname', 'Microsoft JhengHei');
xlabel('取樣點 k (每步 0.1 秒)', 'fontname', 'Microsoft JhengHei');
ylabel('衛星角度 (度)', 'fontname', 'Microsoft JhengHei');
grid on;