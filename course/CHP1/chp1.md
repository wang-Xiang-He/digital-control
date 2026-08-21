# 數位控制系統第一章：導論與系統建模複習筆記

本文件旨在彙整數位控制系統第一章的核心概念，涵蓋系統架構、控制設計流程、物理建模推導以及 MATLAB/Octave 實作分析。

---

## 一、 數位控制系統基本架構與控制問題

數位控制系統（Digital Control Systems）是指在閉迴路系統中包含數位電腦（Digital Computer）作為控制器的系統。電腦的角色是修改閉迴路系統的動態特性，以獲得更令人滿意的系統響應[cite: 1]。

### 1. 主要組成元件與訊號流
在典型的數位控制架構中，其元件功能如下：
*   **受控體 (Plant / Process)**： 欲進行控制的物理系統[cite: 1]。
*   **控制致動器 (Control Actuator)**： 驅動受控體的裝置[cite: 1]。
*   **感測器 (Sensor)**： 量測受控體的輸出響應[cite: 1]。在數位系統中，量測值通常會經過類比數位轉換器（A/D）。
*   **類比數位轉換器 (A/D Converter)**： 將連續時間訊號（如誤差訊號）轉換為電腦可處理的數位二進位形式。這涉及 **採樣 (Sampling)**，其週期為 $T$[cite: 1]。
*   **數位控制器 (Digital Controller)**： 通常由數位電腦擔任，執行數位濾波器演算法（差分方程式），根據誤差訊號計算控制指令[cite: 1]。
*   **數位類比轉換器 (D/A Converter) 與 數據保持器 (Data Hold)**： 將電腦計算的數位指令轉回類比訊號。數據保持器（如零階保持器 ZOH）會將訊號維持在固定值，直到下一個採樣時刻[cite: 1]。
*   **擾動 (Disturbances) 與 雜訊 (Noise)**： 系統中非預期的輸入，例如風力對飛機的影響 $w(t)$，或是感測器（如雷達）無法避免的量測雜訊[cite: 1]。

### 2. 控制系統設計的六大步驟
在實務工程中，解決控制問題通常包含以下標準迭代流程[cite: 1]：
1.  選擇傳感器來量測回授信號[cite: 1]。
2.  選擇致動器來驅動受控體[cite: 1]。
3.  發展受控體、傳感器與致動器的數學模型（微分方程式或轉移函數）[cite: 1]。
4.  根據模型與控制效能指標（擾動拒絕、穩態誤差、暫態響應）設計控制器[cite: 1]。
5.  透過分析、電腦模擬（如 MATLAB/Octave）以及實際硬體測試來評估設計[cite: 1]。
6.  反覆迭代此流程，直到得到滿意的物理系統響應[cite: 1]。

---

## 二、 衛星系統建模 (Satellite Model)

考慮一個球形衛星的航向軸（Yaw-axis）姿態控制，透過推力器產生轉矩來調整角度 $\theta(t)$[cite: 1]。

### 1. 物理方程式推導
假設衛星為剛體且環境無摩擦，根據牛頓第二運動定律的旋轉形式[cite: 1]：
$$J \frac{d^2 \theta(t)}{dt^2} = v(t)$$
其中 $J$ 為衛星繞航向軸的轉動慣量，$v(t)$ 為推力器產生的轉矩[cite: 1]。

### 2. 轉移函數 $G_p(s)$
對上式進行拉普拉斯轉換（忽略初始條件）[cite: 1]：
$$J s^2 \Theta(s) = V(s)$$
$$G_p(s) = \frac{\Theta(s)}{V(s)} = \frac{1}{J s^2}$$
這是一個二階積分系統模型。

### 3. 連續狀態空間模型
定義狀態變數 $x_1(t) = \theta(t)$ 與 $x_2(t) = \dot{\theta}(t)$[cite: 1]：
$$\dot{x}_1(t) = x_2(t)$$
$$\dot{x}_2(t) = \frac{1}{J} v(t)$$
寫成向量矩陣形式[cite: 1]：
$$
\left[ \begin{array}{c} \dot{x}_1(t) \\ \dot{x}_2(t) \end{array} \right] = \left[ \begin{array}{cc} 0 & 1 \\ 0 & 0 \end{array} \right] \left[ \begin{array}{c} x_1(t) \\ x_2(t) \end{array} \right] + \left[ \begin{array}{c} 0 \\ \frac{1}{J} \end{array} \right] v(t)
$$

> **💡 觀念解析與白話文：**
> *   **單位對照**：$J$ 是轉動慣量（單位 $\text{kg} \cdot \text{m}^2$），代表物體抵抗旋轉的能力；$v(t)$ 是力矩（單位 $\text{N} \cdot \text{m}$）。
> *   **狀態空間的本質**：把高階微分方程降維成一階矩陣，是為了讓電腦進行數值運算，也是未來將系統「離散化」寫入微控制器的必經之路。

---

## 三、 直流伺服馬達與機器人關節建模 (Servomotor & Robotic Systems)

直流馬達常用於定位系統（如雷達天線指向系統或工業機器人關節）。本模型採用電樞控制且磁場恆定[cite: 1]。

### 1. 基礎物理方程
*   **電樞電路方程**（忽略電感 $L_a$）[cite: 1]： $e(t) = i(t) R_a + e_m(t)$
*   **反電動勢 (Back EMF)**[cite: 1]： $e_m(t) = K_b \frac{d\theta(t)}{dt}$
*   **電磁轉矩**[cite: 1]： $v(t) = K_T i(t)$
*   **機械平衡方程**[cite: 1]： $v(t) = J \frac{d^2\theta(t)}{dt^2} + B \frac{d\theta(t)}{dt}$

### 2. 轉移函數 $G_p(s)$ 與非線性飽和
聯立上述方程式，取拉普拉斯轉換後可得二階轉移函數[cite: 1]：
$$G_p(s) = \frac{\Theta(s)}{E(s)} = \frac{K_T / J R_a}{s \left( s + \frac{B R_a + K_T K_b}{J R_a} \right)}$$
*(註：若應用於機器人關節，通常會透過齒輪降速比 $n$ 將馬達轉角 $\Theta_m$ 轉換為手臂實際轉角 $\Theta_a$[cite: 1]。)*

### 3. 狀態空間模型
定義 $x_1 = \theta, x_2 = \dot{\theta}$，狀態方程如下[cite: 1]：
$$
\left[ \begin{array}{c} \dot{x}_1 \\ \dot{x}_2 \end{array} \right] = \left[ \begin{array}{cc} 0 & 1 \\ 0 & -\frac{B R_a + K_T K_b}{J R_a} \end{array} \right] \left[ \begin{array}{c} x_1 \\ x_2 \end{array} \right] + \left[ \begin{array}{c} 0 \\ \frac{K_T}{J R_a} \end{array} \right] e(t)
$$

> **💡 觀念解析與白話文：**
> *   **非線性飽和限制 (Saturation)**：實務上功率放大器有最大輸出電壓限制（例如最大 24V）[cite: 1]。當誤差過大時放大器會進入飽和區（Nonlinear mode），工程上為了追求極速反應會刻意利用飽和，但在數學分析時我們固定假設系統運行在線性區[cite: 1]。

---

## 四、 溫控艙熱力學系統 (Temperature Control System)

考慮一恆溫水槽（或熱測試艙），內部液體溫度為 $\tau(t)$，環境溫度為 $\tau_a(t)$[cite: 1]。

### 1. 能量守恆方程式
根據能量守恆定律，供應熱量等於儲存熱量加上流失熱量[cite: 1]：
$$q_e(t) + q_i(t) = q_l(t) + q_o(t) + q_s(t)$$
其中 $q_l = C \frac{d\tau(t)}{dt}$（熱容）、$q_s = \frac{\tau(t) - \tau_a(t)}{R}$（經由艙壁散失的熱量，對應電學的歐姆定律）[cite: 1]。

### 2. 轉移函數與一階滯後模型
假設流率為常數 $V$，忽略擾動後，取拉普拉斯轉換可得一階滯後模型[cite: 1]：
$$G_p(s) = \frac{T(s)}{Q_e(s)} = \frac{K}{\tau s + 1}$$
其中穩態增益 $K = \frac{1}{V H + 1/R}$，時間常數 $\tau = \frac{C}{V H + 1/R}$[cite: 1]。

### 3. 狀態空間模型 ($1 \times 1$ 純量形式)
定義狀態變數 $x(t) = \tau(t)$，系統矩陣縮減為純量形式[cite: 1]：
$$
\begin{bmatrix} \dot{x}(t) \end{bmatrix}
=
\begin{bmatrix} -\frac{1}{C}\left( V H + \frac{1}{R} \right) \end{bmatrix}
\begin{bmatrix} x(t) \end{bmatrix}
+
\begin{bmatrix} \frac{1}{C} \end{bmatrix}
u(t)
$$

> **💡 觀念解析與白話文：**
> *   **一階滯後 (First-Order Lag)**：水槽只有熱容（儲能），沒有慣性也沒有彈簧。給定指令後溫度不會震盪，而是像爬坡一樣平滑上升。熱容 $C$ 越大，爬得越慢。

---

## 五、 單機無限母線電力系統 (SMIB)

SMIB 系統用於分析大型電力系統中同步發電機的動態特性與穩定性[cite: 1]。

### 1. 非線性擺動方程與線性化
根據牛頓運動定律與電力系統物理特性[cite: 1]：
$$\dot{\delta} = \omega - \omega_s$$
$$M \dot{\omega} = P_m - P_e - d \omega$$
其中 $\delta$ 為功角，$M$ 為角動量，$P_e = \frac{E}{x} \sin \delta$[cite: 1]。在平衡點 $(\delta_0, \omega_s)$ 附近進行泰勒展開式線性化（小信號擾動 $\Delta \delta$）[cite: 1]：
$$\Delta P_e \approx \left( \frac{E \cos \delta_0}{x} \right) \Delta \delta = k \Delta \delta$$

### 2. 小信號轉移函數與狀態空間模型
得到以 $\Delta P_m$ 為輸入、$\Delta P_e$ 為輸出的二階轉移函數與狀態空間矩陣[cite: 1]：
$$G_p(s) = \frac{k}{M s^2 + d s + k}$$
$$
\left[ \begin{array}{c} \dot{x}_1 \\ \dot{x}_2 \end{array} \right] = \left[ \begin{array}{cc} 0 & 1 \\ -\frac{k}{M} & -\frac{d}{M} \end{array} \right] \left[ \begin{array}{c} x_1 \\ x_2 \end{array} \right] + \left[ \begin{array}{c} 0 \\ \frac{1}{M} \end{array} \right] \Delta P_m
$$
*(其中 $x_1 = \Delta \delta, x_2 = \Delta \omega$)*[cite: 1]

> **💡 觀念解析與白話文：**
> *   **功角 $\delta$（扭轉的金屬軸）**：發電機與電網之間如同隔了一根彈性金屬軸，油門踩越重軸被扭轉的角度（功角）越大。一旦超過 $90^\circ$ 極限就會失去同步引發大停電。
> *   **數學本質的統一**：發電機矩陣 $A$ 的右下角是阻尼比 $-\frac{d}{M}$，左下角是電網磁力彈簧 $-\frac{k}{M}$，這證明了電力系統在線性化後，本質上就是標準的**二階彈簧阻尼系統**。

---

## 六、 MATLAB / Octave 實作驗證

以下程式碼將四個系統的暫態特性繪製成獨立視窗與一張綜合疊加圖，幫助你直觀理解各系統的動態差異：

```matlab
% 數位控制系統第一章：四系統動態響應比較範例
clear; clc;
set(0, 'DefaultTextFontName', 'Microsoft JhengHei');
set(0, 'DefaultAxesFontName', 'Microsoft JhengHei');

%% 1. 建立模型
J = 0.6; Gp_sat = tf([1], [J 0 0]); % 衛星 (無阻尼二階)
Ra = 2; Kb = 0.1; KT = 0.1; Jm = 0.05; Bm = 0.01;
A22 = -(Bm * Ra + KT * Kb) / (Jm * Ra); B2 = KT / (Jm * Ra);
sys_motor = ss([0 1; 0 A22], [0; B2], [1 0], 0); % 馬達 (帶阻尼一階積分)
M = 0.5; d = 0.1; k = 10; Gp_smib = tf([k], [M d k]); % 發電機 (二階穩定)
C_t = 100; R_t = 2; VH = 0.5; tau = C_t / (VH + 1/R_t); Gain = 1 / (VH + 1/R_t);
Gp_temp = tf([Gain], [tau 1]); % 溫控水槽 (一階滯後)

%% 2. 繪製終極疊加圖 (統一觀察前 50 秒)
figure('Name', '四系統無情疊加圖', 'Position', [100, 100, 1000, 600]);
t = 0:0.1:50; 
[y_sat, t_sat] = step(Gp_sat, t);
[y_motor, t_motor] = step(sys_motor, t);
[y_smib, t_smib] = step(Gp_smib, t);
[y_temp, t_temp] = step(Gp_temp, t);

plot(t_sat, y_sat, 'r', 'LineWidth', 1.5); hold on;
plot(t_motor, t_motor, 'g', 'LineWidth', 1.5);
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