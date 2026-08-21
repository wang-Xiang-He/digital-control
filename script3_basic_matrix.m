% =========================================================================
% 基礎矩陣建立、切片與線性代數運算
% =========================================================================

disp('=== 1. 建立矩陣 (Row vs Column) ===');
% 使用空格或逗號 (,) 來分隔同一個 row 的元素
% 使用分號 (;) 來換到下一個 row
row_vec = [1, 2, 3];          % 1x3 row 向量 (橫向)
col_vec = [4; 5; 6];          % 3x1 column 向量 (直向)
A = [1, 2, 3; 
     4, 5, 6];       % 2x3 矩陣
disp('矩陣 A:');
disp(A);

disp('=== 2. 建立特殊矩陣 (初始化) ===');
Z = zeros(2, 3);              % 2x3 的全零矩陣
disp('2x3 全零矩陣:');
disp(Z)
disp('==========')
O = ones(2, 2);               % 2x2 的全一矩陣
disp('2x2 全一矩陣:');
disp(O)
disp('==========')
I = eye(3);                   % 3x3 的單位矩陣 (Identity Matrix)
disp('3x3 單位矩陣:');
disp(I);

disp('=== 3. 矩陣索引與切片 (Slicing) ===');
% 格式：A(row, column)，索引從 1 開始！
disp('取得 A 的第 2 個 row, 第 3 個 column 元素：');
disp(A(2, 3));                % 輸出 6

disp('取得 A 的完整第 1 個 row：');
disp(A(1, :));                % 冒號 : 代表「該維度的所有元素」

disp('取得 A 的完整第 2 個 column：');
disp(A(:, 2));

disp('=== 4. 矩陣運算 (極度重要) ===');
B = [2, 0, 1; 
     1, 1, 1];

% 4a. 矩陣加減法 (維度必須相同)
disp('A + B :');
disp(A + B);

% 4b. 轉置 (Transpose)
% 加上單引號 ' 即可轉置 (將 row 變成 column，column 變成 row)
disp('A 的轉置矩陣 (A'') :');
disp(A');

% 4c. 矩陣相乘 (Matrix Multiplication)
% A 是 2x3，B' 是 3x2，相乘結果為 2x2
disp('A 乘上 B 的轉置 (A * B'') :');
disp(A * B');
% np 的相乘為 np.dot

% 4d. 逐元素相乘 (Element-wise Multiplication)
% 在運算子前面加上一個小數點「.」，代表不要做線性代數運算，而是對應位置相乘
disp('A 與 B 逐元素相乘 (A .* B) :');
disp(A .* B);
% np 的逐元素相乘為 np.multiply