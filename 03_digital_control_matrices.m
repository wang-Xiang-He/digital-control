% =========================================================================
% 模組三：數位控制專用矩陣運算 (連續離散化、可控/可觀測矩陣、極點配置)
% =========================================================================

% 假設連續時間狀態方程式： dx/dt = A_c * x + B_c * u
A_c = [0, 1; 
      -2, -3];
B_c = [0; 
       1];
C_c = [1, 0];

Ts = 0.1; % 取樣週期 (Sampling period) Ts = 0.1 秒

% -------------------------------------------------------------------------
% 1. 矩陣指數連續系統離散化 (Zero-Order Hold, ZOH)
% -------------------------------------------------------------------------
% 離散狀態轉移矩陣 G = e^(A_c * Ts)
% 警告：矩陣指數必須使用 expm()，不能使用元素級別的 exp()！
G = expm(A_c * Ts); 

% 離散輸入矩陣 H = (int_0^Ts e^(A_c*tau) dtau) * B_c = inv(A_c) * (G - I) * B_c
H = A_c \ (G - eye(size(A_c))) * B_c;

disp('離散狀態矩陣 G (Phi):');
disp(G);
disp('離散輸入矩陣 H (Gamma):');
disp(H);

% 🐍 Python 對照：
% from scipy.linalg import expm
% G = expm(A_c * Ts)              # 注意：不可用 np.exp(A_c * Ts)
% H = np.linalg.solve(A_c, (G - np.eye(A_c.shape[0]))) @ B_c


% -------------------------------------------------------------------------
% 2. 可控制性矩陣 (Controllability Matrix, Ctrb)
% -------------------------------------------------------------------------
% 定義： Mc = [H, G*H, G^2*H, ..., G^(n-1)*H]
% 在 Octave/MATLAB 中，若未安裝 control toolbox，可手動橫向拼接：
n = size(G, 1); % 取得狀態維度 (row 數量)
Mc = [];
for i = 0:(n-1)
    Mc = [Mc, (G^i) * H]; % 水平拼接 column 向量
end

disp('可控制性矩陣 Mc:');
disp(Mc);

% 判斷是否完全可控制 (滿秩： rank(Mc) == n)
if rank(Mc) == n
    disp('>> 系統具備完全可控制性 (Controllable)。');
else
    disp('>> 系統不可控制！');
end

% 🐍 Python 對照：
% import control
% Mc = control.ctrb(G, H) # 或使用 np.hstack([np.linalg.matrix_power(G, i) @ H for i in range(n)])


% -------------------------------------------------------------------------
% 3. 可觀察性矩陣 (Observability Matrix, Obsv)
% -------------------------------------------------------------------------
% 定義： Mo = [C; C*G; C*G^2; ...; C*G^(n-1)]
Mo = [];
for i = 0:(n-1)
    Mo = [Mo; C_c * (G^i)]; % 垂直拼接 row 向量
end

disp('可觀察性矩陣 Mo:');
disp(Mo);

if rank(Mo) == n
    disp('>> 系統具備完全可觀察性 (Observable)。');
else
    disp('>> 系統不可觀察！');
end

% 🐍 Python 對照：
% Mo = control.obsv(G, C_c) # 或使用 np.vstack([C_c @ np.linalg.matrix_power(G, i) for i in range(n)])


% -------------------------------------------------------------------------
% 4. 狀態回授極點配置 (Ackermann 公式求解增益矩陣 K)
% -------------------------------------------------------------------------
% 目標：將閉迴路極點配置在 z1 = 0.2, z2 = 0.3
desired_poles = [0.2, 0.3];

% 目標特徵多項式 alpha(z) = (z - 0.2)(z - 0.3) = z^2 - 0.5z + 0.06
alpha_coeffs = poly(desired_poles); 

% 計算矩陣多項式： alpha(G) = G^2 + a1*G + a2*I
alpha_G = G^2 + alpha_coeffs(2)*G + alpha_coeffs(3)*eye(n);

% Ackermann 公式： K = [0 0 ... 1] * inv(Mc) * alpha_G
e_n = [zeros(1, n-1), 1]; % [0, 1] 向量
K = e_n * inv(Mc) * alpha_G;

disp('計算得到的狀態回授增益矩陣 K:');
disp(K);

% 驗證閉迴路矩陣 (G - H*K) 的極點
closed_loop_poles = eig(G - H * K);
disp('閉迴路極點 (驗證是否符合預期):');
disp(closed_loop_poles);

% 🐍 Python 對照：
% from scipy.signal import place_poles
% # 或 control 模組：
% # K = control.acker(G, H, desired_poles)