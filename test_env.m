% 1. 測試文字輸出與矩陣運算
disp('--- Octave 環境測試開始 ---');
A = [1, 2; 3, 4];
disp('矩陣 A 的反矩陣為：');
disp(inv(A));

% 2. 測試圖形顯示 (合成訊號)
t = 0:0.01:2*pi;
y = sin(2*t) + 0.5*cos(5*t);
figure(1);
plot(t, y, 'LineWidth', 1.5);
title('Composite Signal Test');
xlabel('Time');
ylabel('Amplitude');
grid on;
disp('--- 繪圖視窗應已彈出 ---');

% 3. 暫停程式以保持圖形視窗開啟
disp('請在終端機按下 Enter 鍵以結束程式並關閉圖形...');
pause;