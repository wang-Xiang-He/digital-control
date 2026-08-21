% --- 1. 對應 Python List ---
% 狀況 A：同質資料 (純數字)，使用一般矩陣 Vector
num_list = [10, 20, 30, 40];
disp('取得 List 第二個元素：');
disp(num_list(2)); % 輸出 20

% 狀況 B：異質資料 (數字、字串、矩陣混搭)，使用 Cell Array (大括號)
mixed_list = {1, 'apple', [1, 2; 3, 4]};
disp('取得 Cell Array 第二個元素：');
disp(mixed_list{2}); % 輸出 apple
disp('取得 Cell Array 第三個元素：');
disp(mixed_list{3}); % 輸出 [1, 2; 3, 4]

% --- 2. 對應 Python Dict ---
% 狀況 A：使用 Struct (結構體，最常見)
user_dict.name = 'Alice';
user_dict.age = 25;
user_dict.skills = {'C', 'Python'};
disp('取得 Struct 的 name：');
disp(user_dict.name);

% 狀況 B：使用 containers.Map (支援動態字串 Key，最接近 Dict 行為)
my_map = containers.Map({'key1', 'key2'}, {100, 200});
disp('取得 Map 的 key1：');
disp(my_map('key1'));

% --- 3. 對應 Python Set ---
% Octave 沒有專屬的 Set 型別，而是透過集合函數來處理一般陣列
list_a = [1, 2, 2, 3];
list_b = [3, 4, 5];

% 取得唯一值 (類似 set(list_a))
my_set = unique(list_a); 
disp('Unique 結果：');
disp(my_set); % [1, 2, 3]

% 聯集與交集
set_union = union(list_a, list_b);       % [1, 2, 3, 4, 5]
disp("--- 聯集 ---");
disp(set_union);

set_intersect = intersect(list_a, list_b); % [3]
disp("--- 交集 ---");
disp(set_intersect);