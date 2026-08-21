% =========================================================================
% 模組二：特徵結構分析、特徵多項式與 z 平面穩定度
% =========================================================================

% 定義一個離散系統狀態矩陣 G (2 個 row, 2 個 column)
G = [0.5,  0.2;
    -0.1,  0.8];

% -------------------------------------------------------------------------
% 1. 特徵值與特徵向量 (Eigenvalues & Eigenvectors)
% -------------------------------------------------------------------------
% [V, D] = eig(G)
% V 的每個 column 是對應的特徵向量 (Eigenvector)
% D 是對角矩陣 (Diagonal matrix)，對角線元素為特徵值 (Eigenvalues)
[V, D] = eig(G);

disp('特徵向量矩陣 V (每個 column 代表一個特徵向量):');
disp(V);

disp('特徵值對角矩陣 D:');
disp(D);

% 若只需要特徵值向量，可直接寫：
lambda = eig(G);
disp('lambda = ');
disp(lambda);

% 🐍 Python 對照 (注意回傳格式差異！)：
% w, v = np.linalg.eig(G)
% 差異：
% 1. Python 的 w 是一維陣列 [lambda1, lambda2]，不是對角矩陣。
% 2. Python 的 v 與 Octave 的 V 相同，每個 column 是特徵向量。


% -------------------------------------------------------------------------
% 2. 數位控制穩定度判斷：檢查極點是否在單位圓內 (|z| < 1)
% -------------------------------------------------------------------------
poles_magnitude = abs(lambda); % 取複數的絕對值 (模長 / Magnitude)

disp('極點模長 (|lambda|):');
disp(poles_magnitude);

if all(poles_magnitude < 1.0)
    disp('>> 結論：所有極點位於單位圓內，該數位控制系統為【漸近穩定】。');
else
    disp('>> 結論：存在位於單位圓外或圓上的極點，系統【不穩定】。');
end

% --- 【新增：極點分佈可視化 (Z-plane)】 ---
figure;
theta = linspace(0, 2*pi, 100);
plot(cos(theta), sin(theta), 'k--'); % 畫出單位圓 (邊界)
hold on;
plot(real(lambda), imag(lambda), 'rx', 'MarkerSize', 10, 'LineWidth', 2); % 標示極點位置
axis equal; % 讓 x, y 軸比例一致，圓才不會變橢圓
grid on;
try graphics_toolkit('qt'); catch; end % 嘗試切換為 qt 引擎以獲得更好的字體渲染
title('Z-平面極點分佈圖 (Pole Locations on Z-plane)', 'FontName', 'Microsoft JhengHei');
xlabel('實部 (Real Axis)', 'FontName', 'Microsoft JhengHei');
ylabel('虛部 (Imaginary Axis)', 'FontName', 'Microsoft JhengHei');
legend('單位圓 (|z|=1) - 穩定邊界', '系統極點', 'Location', 'northeast');
set(gca, 'FontName', 'Microsoft JhengHei'); % 將坐標軸與圖例字體設定為微軟正黑體
hold off;

% 🐍 Python 對照：
% poles_magnitude = np.abs(w)
% is_stable = np.all(poles_magnitude < 1.0)


% -------------------------------------------------------------------------
% 3. 特徵多項式 (Characteristic Polynomial) 與求解根
% -------------------------------------------------------------------------
% poly(G) 計算 det(z*I - G) = 0 的係數： z^2 + a1*z + a2
char_poly = poly(G);
disp('特徵方程式係數 [1, a1, a2]:');
disp(char_poly);

% 由多項式係數反求特徵根 (極點)
calculated_roots = roots(char_poly);
disp('由特徵方程式求得的根:');
disp(calculated_roots);

% 🐍 Python 對照：
% char_poly        = np.poly(G)
% calculated_roots = np.roots(char_poly)


% -------------------------------------------------------------------------
% 4. 矩陣對角化 (Diagonalization) 與相似轉換
% -------------------------------------------------------------------------
% 若 V 為特徵向量矩陣，則 inv(V) * G * V = D
G_diag = inv(V) * G * V;
disp('對角化驗證 (應等於 D):');
disp(round(G_diag * 10000) / 10000);

% 🐍 Python 對照：
% G_diag = np.linalg.inv(v) @ G @ v