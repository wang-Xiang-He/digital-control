# CHP2 輔助工具使用說明

這個資料夾除了課程內容（`chp2.m` / `chp2.ipynb` / `chp2.md`），還放了三個補丁檔，
用來補上 **Octave 相對於 MATLAB 缺少的功能**。三個檔都是**專案內自足**的——
資料夾搬到哪台機器都能用，不需要安裝到系統或家目錄。

| 檔案 | 補什麼 |
|---|---|
| `iztrans.m` | 反 z 轉換。Octave 的 symbolic 套件到 3.2.2 都沒實作 `iztrans` |
| `ztrans_cf.m` | z 轉換的**閉合形式**。套件的 `ztrans` 常常只回傳未求和的 `Sum` |
| `sym_magic.py` | Jupyter 裡把符號運算式用 **LaTeX** 渲染（`%sym` / `%%sym`） |

---

## 1. 一次性環境設定（每台機器做一次）

### 1.1 Octave 套件

```matlab
pkg load control     % tf, c2d, ss, margin, bode...
pkg load symbolic    % syms, ztrans, ilaplace...
pkg load signal      % ss2tf  ← MATLAB 放在 Control System Toolbox，Octave 在這
```

> ⚠ `ss2tf` 在 Octave 屬於 `signal` 套件。只 `pkg load control` 會出現
> `error: 'ss2tf' undefined`。

### 1.2 Jupyter kernel（只有要用 `.ipynb` 才需要）

```bash
pip install octave_kernel
python -m octave_kernel install --user
```

裝完**務必**編輯 kernel.json，指定用 `octave-cli.exe`：

`~/AppData/Roaming/jupyter/kernels/octave/kernel.json`
```json
{
  "argv": ["<python路徑>", "-m", "octave_kernel", "-f", "{connection_file}"],
  "display_name": "Octave",
  "language": "octave",
  "name": "octave",
  "env": {
    "OCTAVE_EXECUTABLE": "D:\octave\octave-11.3.0-w64\mingw64\bin\octave-cli.exe"
  }
}
```

> ⚠ **不加這個 `env` 會一直跳錯誤視窗。** octave_kernel 預設會挑 `octave.EXE`
> （GUI 版），而 GUI 版在非互動情境下 Qt 初始化會失敗：
> `This application failed to start because no Qt platform plugin could be initialized`
> （exit code `3221227010` = `0xC0000142`，DLL 初始化失敗）。
> `octave-cli.exe` 完全不碰 Qt，沒有這個問題。

VS Code 裡選 kernel：`Ctrl+Shift+P` → `Developer: Reload Window` →
開啟 `.ipynb` → 右上角 kernel 選擇器 → `Select Another Kernel...` →
`Jupyter Kernel...` → **Octave**。

---

## 2. 在 `.m` 腳本裡用

`.m` 檔跟這兩個函式檔放在同一個資料夾，直接叫名字就好，**不需要 import**：

```matlab
iztrans(z/((z-1)*(z-2)), k)      % -> 2^k - 1
ztrans_cf(exp(-a*k*T), k, z)     % -> z/(z - exp(-a*T))
```

Octave 靠 **load path** 找函式：檔名 = 函式名，檔案在 path 上就找得到。
當前工作目錄（`.`）永遠在 path 上。

### 從別的資料夾執行時

| 執行方式 | 找得到嗎 |
|---|---|
| `cd` 到本資料夾再跑 | ✅ |
| `run('<絕對路徑>/chp2.m')` | ✅（`run` 會先 `cd` 進腳本目錄） |
| `octave <絕對路徑>/chp2.m` | ❌ |
| `source('<絕對路徑>/chp2.m')` | ❌ |

要四種都穩，在腳本開頭加這兩行（CHP8 就是這樣寫的）：

```matlab
this_dir = fileparts(mfilename('fullpath'));
if ~isempty(this_dir), addpath(this_dir); end
```

用 `mfilename('fullpath')` 而不是 `'../lib'` 這種相對路徑，是因為相對路徑
是相對於**當前工作目錄**，不是腳本位置。

---

## 3. 在 Notebook 裡用

### 3.1 第一個 cell：載入 LaTeX magic

```python
%%python
import os, sys
sys.path.insert(0, os.getcwd())
import sym_magic
sym_magic.register_magics(kernel)
```

kernel 的工作目錄就是 notebook 所在資料夾，所以 `os.getcwd()` 剛好指到這裡，
**不需要寫死任何絕對路徑**，換機器照樣能用。

（`%%python` 是 metakernel 內建的 magic，它會把 `kernel` 物件暴露給 Python，
我們就用它把 `sym_magic.py` 註冊進去。）

### 3.2 計算

```matlab
pkg load symbolic;
syms a positive
syms T positive
syms b real
syms k z
[Ez, roc] = ztrans_cf(a^(k*T)*cos(b*k*T), k, z);
```

### 3.3 用 LaTeX 顯示

```
%%sym
Ez
roc
```

渲染成：

$$\frac{z\left(z - a^{T}\cos(Tb)\right)}{a^{2T} - 2a^{T}z\cos(Tb) + z^{2}}
\qquad\qquad \frac{a^{T}}{|z|} < 1$$

也可以用 line magic 混在一般 cell 裡：

```matlab
Ez = ztrans_cf(exp(-a*k*T), k, z);
%sym Ez
```

> `%%sym` 是 **cell magic**，整格都會被它接管，不會執行 Octave 程式碼，
> 所以計算和顯示要分成兩格。`%sym` 是 line magic，可以混用。

### 3.4 不想用 LaTeX 的話

```matlab
sympref('display', 'unicode')   % 用 ─ │ ⎛⎞ 排版，比預設好看
sympref('display', 'flat')      % 單行，方便複製
sympref('display', 'ascii')     % 預設，用 / \ - 拼
```

---

## 4. 函式參考

### `iztrans(F)` / `iztrans(F, k)` / `iztrans(F, z, k)`

反 z 轉換。引數慣例與 MATLAB Symbolic Math Toolbox 相同。

用**留數法**：$e(k) = \sum_{\text{poles }p} \operatorname{Res}\left[E(z)z^{k-1}\right]_{z=p}$

對有理的 $E(z)$ 有效，單根、重根、共軛複根皆可。

```matlab
syms z k
iztrans(z/((z-1)*(z-2)), k)     % 2^k - 1
iztrans(z/(z-1)^2, k)           % k          （重根）
iztrans(z/(z^2+1), k)           % 共軛複根，結果等價於 sin(pi*k/2)
```

> 共軛複根的結果會是 `I*(-I^k + (-I)^k)/2` 這種指數形式。**數值是對的**
> （代 k=0..5 得 0,1,0,-1,0,1），但 SymPy 不會自動化成三角形式。

### `[F, roc] = ztrans_cf(f)` / `(f, z)` / `(f, k, z)`

z 轉換，強制求出收斂域內的閉合形式（cf = closed form）。

```matlab
syms a b k T z
ztrans_cf(exp(-a*k*T), k, z)          % z/(z - exp(-a*T))
ztrans_cf(a^(k*T)*cos(b*k*T), k, z)   % z(z - a^T cos bT)/(z² - 2a^T z cos bT + a^(2T))
```

**為什麼需要這個？** 套件的 `ztrans` 直接把定義式丟給 SymPy 求和。遇到
`exp(-a*k*T)` 這種底數正負大小未知的項，SymPy 判斷不出 `|底數/z| < 1`
是否成立，就原封不動回傳未求和的 `Sum`。

**`assume` 解決不了**——收斂條件是「兩個自由符號之間的不等式」，
不在 SymPy 假設系統的表達能力內。

**實際做法**是替換：把每個「底數^(c·k)」的底數換成單一啞符號 `q`，
SymPy 對 `Sum(q^k·z^(-k))` 有現成的幾何級數公式，會回傳一個 Piecewise；
取其收斂支，在 q 空間化簡後再把 q 代回。

#### ⚠ 它不驗證收斂，它假設收斂

取 Piecewise 的第一支 = **宣告自己位在 ROC 內**，跟課本查 z 轉換表的前提一樣。
第二個回傳值會告訴你它假設了什麼：

```matlab
[Ez, roc] = ztrans_cf(a^(k*T)*cos(b*k*T), k, z);
roc    % a^T/|z| < 1   即 |z| > a^T
```

**判斷參數落不落在 ROC 內是你的責任。**

#### 假設在這裡才有用

假設沒辦法讓級數算得動，但能把 ROC 化乾淨：

| 宣告方式 | 得到的 ROC |
|---|---|
| `syms a b T` | `e^(-im(Tb))·│a^T/z│ < 1 ∧ e^(im(Tb))·│a^T/z│ < 1` |
| `syms a positive; syms T positive; syms b real` | `a^T/│z│ < 1` |

#### 引數位置

```matlab
ztrans_cf(f,  k,  z)
%            ↑   ↑
%            │   └── 輸出變數（新生出來的）
%            └────── 時間索引（要被 Σ 消掉的）
```

**名字隨你取，但位置決定角色**，而且位置錯了不會報錯：

```matlab
ztrans_cf(exp(-a*n*T), n, w)   % w/(w - exp(-T*a))   ✅ 名字可以換
ztrans_cf(1^k, z, k)           % k/(k - 1)           ❌ 對 z 求和了，垃圾結果
```

---

## 5. 自我測試

兩個 `.m` 檔都內嵌了測試（`%!test` 區塊），隨時可以驗證：

```matlab
test iztrans      % PASSES 6 out of 6 tests
test ztrans_cf    % PASSES 7 out of 7 tests
```

`ztrans_cf` 的測試逐條比對課本 z 轉換表：$1$、$e^{-akT}$、$kTe^{akT}$、
$a^{kT}\cos(bkT)$、$a^{kT}\sin(bkT)$。

`help iztrans` / `help ztrans_cf` 可以看完整說明。

---

## 6. 踩過的坑

| 症狀 | 原因 | 解法 |
|---|---|---|
| `could not find any INDEX file in .../control-4.2.3` | 手動 `pkg install` 失敗，但資料庫已登記，指向不存在的目錄 | `pkg uninstall control` 清掉殘留紀錄 |
| `pkg install` 報 `C++ compiler cannot create executables` | `cc1plus.exe` 撿到 `C:\Program Files\Git\mingw64\bin` 的舊 `libstdc++-6.dll` | 安裝時把 Octave 的 `mingw64\bin` 和 `usr\bin` 排到 PATH 最前面 |
| `pkg install` 報 `make: command not found` | Octave 自帶的 `make.exe` 在 `usr\bin`，不在 PATH 上 | 同上 |
| notebook 一直跳 Qt 錯誤視窗 | kernel 用了 GUI 版 `octave.EXE` | kernel.json 加 `OCTAVE_EXECUTABLE` 指向 `octave-cli.exe` |
| `pycall_sympy__` 報 `IndentationError` / `too many values to unpack` | 傳給 SymPy 的 Python 程式碼字串裡放了**中文註解** | 註解移到 Octave 層，Python 區塊只留 ASCII |
| `ilaplace(F)` 之後 `subs(et, t, k*T)` 沒作用 | 單引數的 `ilaplace` 會自建一個**帶假設的** `t`，跟 `syms t` 不是同一個符號 | 寫成 `ilaplace(F, s, t)`，明確指定變數 |
| `warning: passing floating-point values to sym is dangerous` | 把 double `0.1` 餵給符號運算 | 改用 `sym(1)/10` |
| 在 `[]` 裡寫 `[a (1)]` 得到 `[a, 1]` 而不是 `a(1)` | 中括號內**空白是欄位分隔符** | `[]` / `{}` 裡函式呼叫不要加空格 |

### 不要把檔案命名為 `ztrans.m`

path 上的 `.m` 檔會**遮蔽**同名函式。

- `iztrans` — 套件沒有，所以命名為 `iztrans.m` 安全，不會蓋到東西
- `ztrans` — **套件有**，命名為 `ztrans.m` 會把真貨頂掉，所以這裡叫 `ztrans_cf.m`

放 `@sym/ztrans.m` 覆寫套件方法**技術上可行但別用**：只有 `addpath` 排在最後
一次 `pkg load symbolic` 之後才生效，順序反了就**無聲失效**，notebook 裡
重跑一次 cell 就翻車。
