# 數位控制系統　期中考總複習

**教材**：C. L. Phillips, H. T. Nagle, A. Chakrabortty, *Digital Control Systems: Analysis & Design*, 4/e

---

## 0. 考試範圍判定

依課程進度表：

| 週次 | 內容 | 對應章節 |
|---|---|---|
| Week 1–2 | Introduction | **Ch. 1** |
| Week 3–4 | Discrete-time systems and the z-transform | **Ch. 2** |
| Week 5–6 | Sampling and reconstruction | **Ch. 3** |
| Week 7–8 | Open-loop discrete-time systems | **Ch. 4** |
| **Week 9** | **Midterm Exam** | ← 考到這裡 |
| Week 10–11 | Closed-loop systems | Ch. 5（期中後才上，**不考**） |

$$
\boxed{\text{期中考範圍：第 1 章 ～ 第 4 章}}
$$

**份量分配建議**（依教材篇幅與課堂週數）：

| 章 | 週數 | 教材頁數 | 預估比重 | 讀書優先序 |
|---|---|---|---|---|
| Ch. 1 導論與建模 | 2 | 24 | 約 10–15% | 低（觀念題為主） |
| **Ch. 2 離散系統與 z 轉換** | 2 | 65 | **約 35–40%** | **最高** |
| Ch. 3 取樣與重建 | 2 | 26 | 約 20% | 中高 |
| **Ch. 4 開迴路離散系統** | 2 | 41 | **約 30%** | **高** |

> **策略**：Ch. 2 與 Ch. 4 是計算題主力（合計約 70%），一定要練熟；Ch. 1 多為觀念與建模，Ch. 3 是觀念加頻率響應計算。

---

## 1. 第一章：導論與四大建模範例

### 1.1 閉迴路系統的基本組成

```text
期望響應 ──►(+)──► 誤差 ──► 補償器 ──► 受控體(含致動器) ──► 響應
            ▲(-)                                          │
            └──────────────── 感測器 ◄────────────────────┘
```

| 元件 | 功能 |
|---|---|
| 受控體 Plant（含致動器） | 真正要被控制的物理系統 |
| 感測器 Sensor | 量測實際響應 |
| 誤差訊號 | 期望響應 − 感測器量到的響應 |
| 補償器 Compensator | 把誤差「加工」成合適的受控體輸入 |

> **考點**：為什麼不能把誤差直接送進受控體？因為得到的響應通常不理想（太慢、太震盪、甚至不穩定），**必須依受控體動態特性設計補償器**。

### 1.2 兩個必背定義

**線性系統（疊加原理）**：

$$
\text{輸入 }a_1x_1(t)+a_2x_2(t)\ \Longrightarrow\ \text{輸出 }a_1y_1(t)+a_2y_2(t)
$$

**非時變系統**：參數不隨時間改變。（反例：太空載具助推段，燃料消耗使質量隨時間變化。）

### 1.3 標準負回授迴路

$$
\boxed{\frac{C(s)}{R(s)}=\frac{G_c(s)G_p(s)}{1+G_c(s)G_p(s)H(s)}}
$$

### 1.4 四大建模範例（**必背轉移函數**）

| 系統 | 物理方程式 | 轉移函數 $G_p(s)$ | 動態特性 |
|---|---|---|---|
| **衛星**（1.4） | $J\ddot\theta=v(t)$ | $\dfrac{1}{Js^2}$ | 二階純積分，**無阻尼、發散** |
| **伺服馬達**（1.5） | $J\ddot\theta+\left(\dfrac{BR_a+K_TK_b}{R_a}\right)\dot\theta=\dfrac{K_T}{R_a}e$ | $\dfrac{K_T/(JR_a)}{s\left(s+\frac{BR_a+K_TK_b}{JR_a}\right)}$ | 積分 + 一階 |
| **溫控**（1.6） | $C\dot\theta+\left(VH+\frac1R\right)\theta=q_e+\cdots$ | $\dfrac{K}{\tau s+1}$ | 一階滯後，**平滑不震盪** |
| **SMIB 發電機**（1.7） | $M\dot\omega=P_m-P_e-d\omega$（線性化後） | $\dfrac{k}{Ms^2+ds+k}$ | **穩定二階彈簧阻尼** |

**衛星的狀態空間**（後面各章反覆出現，務必背熟）：

$$
\begin{bmatrix}\dot x_1\cr \dot x_2\end{bmatrix}=\begin{bmatrix}0&1\cr0&0\end{bmatrix}\begin{bmatrix}x_1\cr x_2\end{bmatrix}+\begin{bmatrix}0\cr 1/J\end{bmatrix}v(t),
\qquad y=\begin{bmatrix}1&0\end{bmatrix}\mathbf x
$$

**溫控系統的參數**（可能考代數）：

$$
\tau=\frac{C}{VH+1/R},\qquad K_1=\frac{1}{VH+1/R},\qquad K_2=\frac{VH}{VH+1/R},\qquad K_3=\frac{1/R}{VH+1/R}
$$

**SMIB 線性化**：$\sin\phi\approx\sin\phi_0+\cos\phi_0\cdot\Delta\phi$，同步功率係數 $k=\dfrac{E\cos\phi_0}{x}$，且 $P_e=\dfrac{E}{x}\sin\phi$。

### 1.5 六大設計步驟與四項準則

**六大步驟**：選感測器 → 選致動器 → 建立數學模型 → 設計控制器 → 評估（分析、模擬、實測） → **反覆迭代**。

**四項控制準則**：干擾抑制、穩態誤差、暫態響應、參數敏感度。

> **常考觀念題**：實務上的主要困難不在數學求解，而在**「問題形式化」與「解答轉譯」**這兩個銜接物理與數學的步驟。

---

## 2. 第二章：離散時間系統與 z 轉換（**本次考試重點**）

### 2.1 z 轉換的定義

$$
\boxed{E(z)=\mathcal{Z}[e(k)]=\sum_{k=0}^{\infty}e(k)z^{-k}=e(0)+e(1)z^{-1}+e(2)z^{-2}+\cdots}
$$

### 2.2 z 轉換性質總表（**必背**）

| 數列 | 轉換 |
|---|---|
| $a_1e_1(k)+a_2e_2(k)$ | $a_1E_1(z)+a_2E_2(z)$ |
| **$e(k-n)u(k-n)$，$n\ge0$（延遲）** | $\boxed{z^{-n}E(z)}$ |
| **$e(k+n)u(k)$，$n\ge1$（超前）** | $\boxed{z^n\left[E(z)-\sum_{k=0}^{n-1}e(k)z^{-k}\right]}$ |
| $a^{kT}e(k)$（複數平移） | $E(z/a^T)$ |
| $k\,e(k)$ | $-z\dfrac{dE(z)}{dz}$ |
| $e_1(k)*e_2(k)$（摺積） | $E_1(z)E_2(z)$ |
| $\sum_{n=0}^{k}e(n)$ | $\dfrac{z}{z-1}E(z)$ |
| **初值定理** | $\boxed{e(0)=\lim_{z\to\infty}E(z)}$ |
| **終值定理** | $\boxed{e(\infty)=\lim_{z\to1}(z-1)E(z)}$ |

> **⚠️ 最容易錯的地方**：**延遲**是乾淨的 $z^{-n}E(z)$；**超前**要**扣掉前 $n$ 項** $\sum_{k=0}^{n-1}e(k)z^{-k}$。
>
> **物理理由**：右移（延遲）不會遺失資訊；左移（超前）會把最前面 $n$ 個值「甩出視窗外」，所以要補償。

> **⚠️ 終值定理的成立條件**：$E(z)$ 的所有極點必須在單位圓內，**最多允許 $z=1$ 有一個單重極點**。不滿足就不能用（第 7 章證明）。

### 2.3 常用 z 轉換表（**必背**，假設 $T=1$）

| $e(k)$ | $E(z)$ |
|---|---|
| $\delta(k-n)$ | $z^{-n}$ |
| $1$（單位步階） | $\dfrac{z}{z-1}$ |
| $k$ | $\dfrac{z}{(z-1)^2}$ |
| $k^2$ | $\dfrac{z(z+1)}{(z-1)^3}$ |
| $a^k$ | $\dfrac{z}{z-a}$ |
| $ka^k$ | $\dfrac{az}{(z-a)^2}$ |
| $\sin ak$ | $\dfrac{z\sin a}{z^2-2z\cos a+1}$ |
| $\cos ak$ | $\dfrac{z(z-\cos a)}{z^2-2z\cos a+1}$ |
| $a^k\sin bk$ | $\dfrac{az\sin b}{z^2-2az\cos b+a^2}$ |
| $a^k\cos bk$ | $\dfrac{z^2-az\cos b}{z^2-2az\cos b+a^2}$ |

**含取樣週期 $T$ 的版本**（把 $k\to kT$、$a\to a^T$）：

$$
\mathcal{Z}[e^{-akT}]=\frac{z}{z-e^{-aT}},\qquad \mathcal{Z}[kT]=\frac{Tz}{(z-1)^2},\qquad \mathcal{Z}[kTa^{kT}]=\frac{Ta^Tz}{(z-a^T)^2}
$$

### 2.4 由 $E(s)$ 求 $E(z)$（**必考題型**）

**標準步驟**：

1. 把 $E(s)$ 做**部分分式展開**，拆成一次極點的和
2. 逐項套用 $\dfrac{1}{s+a}\ \to\ \dfrac{z}{z-e^{-aT}}$，用線性性質相加

**範例**（例 2.9）：$E(s)=\dfrac{s^2+4s+3}{s^3+6s^2+8s}=\dfrac{s^2+4s+3}{s(s+2)(s+4)}$

留數法求係數（$K_i=(s-p_i)E(s)\big|_{s=p_i}$）：

$$
K_0=\frac{3}{(2)(4)}=0.375,\qquad K_1=\frac{4-8+3}{(-2)(2)}=0.25,\qquad K_2=\frac{16-16+3}{(-4)(-2)}=0.375
$$

$$
E(s)=\frac{0.375}{s}+\frac{0.25}{s+2}+\frac{0.375}{s+4}
\ \Longrightarrow\
E(z)=\frac{0.375z}{z-1}+\frac{0.25z}{z-e^{-2T}}+\frac{0.375z}{z-e^{-4T}}
$$

### 2.5 差分方程式的求解（**必考題型**）

**步驟**：

1. 對整條差分方程式取 z 轉換（**用實數平移定理，注意初始條件**）
2. 解出 $Y(z)$
3. 取反 z 轉換

> **關鍵**：若方程式含 $y(k+1)$、$y(k+2)$ 這類**超前項**，一定要用超前公式**扣掉初始項**：
> $$\mathcal{Z}[y(k+1)]=z[Y(z)-y(0)],\qquad \mathcal{Z}[y(k+2)]=z^2\left[Y(z)-y(0)-y(1)z^{-1}\right]$$

### 2.6 反 z 轉換的四種方法（**必考，要會比較**）

| 方法 | 做法 | 優點 | 限制 |
|---|---|---|---|
| **① 冪級數（長除法）** | 把 $E(z)$ 長除成 $e_0+e_1z^{-1}+\cdots$ | 簡單，**總能算出有限個 $e(k)$** | **通常得不到 $e(k)$ 的封閉公式** |
| **② 部分分式展開** | **先展開 $\dfrac{E(z)}{z}$**，再乘回 $z$ 查表 | **能得到封閉公式**，最常用 | 重根、複根較麻煩 |
| **③ 反演積分（留數法）** | $e(k)=\sum\text{Res}\left[E(z)z^{k-1}\right]$ | 理論完整 | 計算繁瑣 |
| **④ MATLAB** | `iztrans`、`residue`、`filter` | 快 | 考試不能用 |

> **⚠️ 方法 ② 的關鍵技巧（最常考、最常錯）**：
>
> **必須先展開 $\dfrac{E(z)}{z}$ 而不是 $E(z)$。**
>
> **理由**：z 轉換表中每一項的分子都帶一個 $z$（例如 $\dfrac{z}{z-a}\to a^k$）。先除以 $z$ 展開，每項才會是 $\dfrac{K_i}{z-p_i}$，最後乘回 $z$ 就變成可查表的 $\dfrac{K_iz}{z-p_i}$。

**範例**（例 2.12、2.13）：$E(z)=\dfrac{z}{z^2-3z+2}=\dfrac{z}{(z-1)(z-2)}$

**長除法**：$E(z)=z^{-1}+3z^{-2}+7z^{-3}+15z^{-4}+\cdots$ → $e(0)=0,e(1)=1,e(2)=3,e(3)=7,\dots$

**部分分式**：

$$
\frac{E(z)}{z}=\frac{1}{(z-1)(z-2)}=\frac{-1}{z-1}+\frac{1}{z-2}
\ \Longrightarrow\
E(z)=\frac{-z}{z-1}+\frac{z}{z-2}
$$

$$
\boxed{e(k)=-1+2^k=2^k-1}
$$

**驗證**：$e(0)=0$ ✓，$e(1)=1$ ✓，$e(2)=3$ ✓，$e(3)=7$ ✓

### 2.7 狀態變數模型（**必考**）

**標準形式**：

$$
\mathbf x(k+1)=A\mathbf x(k)+B\mathbf u(k),\qquad \mathbf y(k)=C\mathbf x(k)+D\mathbf u(k)
$$

**維度**（$n$ 狀態、$m$ 輸入、$p$ 輸出）：$A$ 是 $n\times n$、$B$ 是 $n\times m$、$C$ 是 $p\times n$、$D$ 是 $p\times m$。

#### 由轉移函數建狀態模型（三步驟）

1. 由 $G(z)$ 畫**模擬圖**（simulation diagram）
2. 把**每個時間延遲 $z^{-1}$ 的輸出**標為一個狀態變數
3. 由模擬圖寫出狀態方程式

#### 可控標準式（CCF）

給定 $G(z)=\dfrac{b_{n-1}z^{n-1}+\cdots+b_0}{z^n+a_{n-1}z^{n-1}+\cdots+a_0}$：

$$
A=\begin{bmatrix}0&1&0&\cdots&0\cr 0&0&1&\cdots&0\cr \vdots&&&\ddots&\vdots\cr 0&0&0&\cdots&1\cr -a_0&-a_1&-a_2&\cdots&-a_{n-1}\end{bmatrix},\quad
B=\begin{bmatrix}0\cr0\cr\vdots\cr0\cr1\end{bmatrix},\quad
C=\begin{bmatrix}b_0&b_1&\cdots&b_{n-1}\end{bmatrix}
$$

> **記法**：$A$ 的**最後一列**是分母係數**取負號、由低次到高次**；上面是一條「往右上移一格」的單位對角線。

#### 相似轉換

$$
\mathbf w(k)=P^{-1}\mathbf x(k)\ \Longrightarrow\
A_w=P^{-1}AP,\quad B_w=P^{-1}B,\quad C_w=CP,\quad D_w=D
$$

> **⚠️ 必考觀念**：**相似轉換不改變系統的特徵值（極點）與轉移函數**，只改變狀態變數的「座標」。

**對角化**：若 $P$ 的各行是 $A$ 的**特徵向量**，則 $A_w=P^{-1}AP=\Lambda$ 為對角矩陣，對角元素就是特徵值。

### 2.8 由狀態方程式求轉移函數（**必考公式**）

$$
\boxed{G(z)=\frac{Y(z)}{U(z)}=C\left[zI-A\right]^{-1}B+D}
$$

**推導**：對 $\mathbf x(k+1)=A\mathbf x(k)+B\mathbf u(k)$ 取 z 轉換（零初始條件）得 $z\mathbf X=A\mathbf X+B\mathbf U$，即 $\mathbf X=[zI-A]^{-1}B\mathbf U$；代入 $\mathbf Y=C\mathbf X+D\mathbf U$ 即得。

> **特徵方程式**：$\det(zI-A)=0$，其根就是系統極點（等於 $A$ 的特徵值）。

**$2\times2$ 反矩陣公式**（考試常用）：

$$
\begin{bmatrix}a&b\cr c&d\end{bmatrix}^{-1}=\frac{1}{ad-bc}\begin{bmatrix}d&-b\cr -c&a\end{bmatrix}
$$

### 2.9 狀態方程式的解（**必考**）

**遞迴解**（直接代入）：

$$
\boxed{\mathbf x(k)=A^k\mathbf x(0)+\sum_{j=0}^{k-1}A^{k-1-j}B\mathbf u(j)}
$$

| 項 | 名稱 | 意義 |
|---|---|---|
| $A^k\mathbf x(0)$ | **零輸入響應** | 初始條件自己演化 |
| $\sum A^{k-1-j}B\mathbf u(j)$ | **零狀態響應** | 輸入累積的貢獻（**離散摺積**） |

**狀態轉移矩陣**：

$$
\boxed{\Phi(k)=A^k=\mathcal{Z}^{-1}\left[(zI-A)^{-1}z\right]}
$$

**三個性質**：

$$
\Phi(0)=I,\qquad \Phi(k_2-k_1)\Phi(k_1-k_0)=\Phi(k_2-k_0),\qquad \Phi^{-1}(k)=\Phi(-k)
$$

---

## 3. 第三章：取樣與重建

### 3.1 全章最核心的分解（式 3-2）

零階保持器輸出的拉氏轉換恰好可以因式分解成兩塊：

$$
\boxed{\bar E(s)=\underbrace{\left[\sum_{n=0}^{\infty}e(nT)e^{-nTs}\right]}_{\text{只和訊號有關}\ \to\ E^*(s)}\underbrace{\left[\frac{1-e^{-Ts}}{s}\right]}_{\text{只和 }T\text{ 有關}\ \to\ G_{h0}(s)}}
$$

```text
       ┌─────────────┐         ┌──────────────────┐
e(t)   │  理想取樣器  │  E*(s)  │  (1 - e^{-Ts})/s │   ē(t)
─────► │   （開關）   ├────────►│   資料保持器      ├──────►
E(s)   └─────────────┘         └──────────────────┘
```

> **⚠️ 三個必答的觀念題**
> 1. **$E^*(s)$ 在實體系統中不存在**——它只是因式分解跑出來的中間量。
> 2. 圖中的開關**不是**實體取樣器，方塊**不是**實體保持器；**但兩者串聯確實準確描述實體裝置的輸入輸出特性**。
> 3. **取樣器沒有轉移函數**——因為許多不同的輸入會產生相同的 $E^*(s)$（多對一），而轉移函數要求一對一。**這是第 4 章一切困難的根源。**

### 3.2 星號轉換與理想取樣器

$$
\boxed{E^*(s)=\sum_{n=0}^{\infty}e(nT)e^{-nTs}}\qquad\text{（式 3-3，定義）}
$$

$$
e^*(t)=e(0)\delta(t)+e(T)\delta(t-T)+\cdots=e(t)\delta_T(t)
$$

| 觀念 | 內容 |
|---|---|
| $e^*(t)$ 是什麼 | **脈衝串**，每根脈衝的**權重（面積）= 該瞬間的訊號值** |
| 為什麼叫「理想」 | 輸出含**非物理的脈衝函數** |
| 別名 | **脈衝調變器**（載波 $=\delta_T(t)$，調變訊號 $=e(t)$） |
| 不連續點的規定 | 若 $e(t)$ 在 $t=kT$ 不連續，取 **$e(kT^+)$**（右極限） |

**零階保持器**：

$$
\boxed{G_{h0}(s)=\frac{1-e^{-Ts}}{s}}
$$

### 3.3 $E^*(s)$ 的三種求法

| 式號 | 公式 | 用途 |
|---|---|---|
| (3-3) | $E^*(s)=\sum_{n=0}^{\infty}e(nT)e^{-nTs}$ | 定義；配合**幾何級數**求封閉形式 |
| (3-10) | $E^*(s)=\sum_{\text{poles of }E(\lambda)}\text{Res}\left[E(\lambda)\dfrac{1}{1-e^{-T(s-\lambda)}}\right]$ | **產生 z 轉換表** |
| (3-11) | $E^*(s)=\dfrac1T\sum_{n=-\infty}^{\infty}E(s+jn\omega_s)+\dfrac{e(0)}{2}$ | **推出頻譜複製與混疊** |

**幾何級數**（考試最常用）：$\dfrac{1}{1-x}=1+x+x^2+\cdots$（$\lvert x\rvert<1$）

**例 3.1**（單位步階）：$E^*(s)=1+e^{-Ts}+e^{-2Ts}+\cdots=\dfrac{1}{1-e^{-Ts}}$

**例 3.2**（$e^{-t}$）：$E^*(s)=\dfrac{1}{1-e^{-(1+s)T}}$

**例 3.4**（$\sin\omega_0t$）：$E^*(s)=\dfrac{e^{-Ts}\sin\omega_0T}{1-2e^{-Ts}\cos\omega_0T+e^{-2Ts}}$

### 3.4 $E^*(s)$ 的兩個性質（**必考**）

**性質 1：對 $s$ 週期，週期為 $j\omega_s$**

$$
\boxed{E^*(s+jm\omega_s)=E^*(s)}
$$

**證明關鍵**：$\omega_sT=\dfrac{2\pi}{T}\cdot T=2\pi$，因此 $e^{-jnm\omega_sT}=e^{-jnm2\pi}=1$。

**性質 2：極點以 $j\omega_s$ 為間隔複製**

$$
E(s)\text{ 在 }s=s_1\text{ 有極點}\ \Longrightarrow\ E^*(s)\text{ 在 }s=s_1+jm\omega_s\text{ 都有極點}
$$

> **⚠️ 零點沒有對應結論**——$E(s)$ 的零點位置**無法**唯一決定 $E^*(s)$ 的零點位置。

**主帶（primary strip）**：$-\dfrac{\omega_s}{2}\le\omega\le\dfrac{\omega_s}{2}$。只要知道主帶內的極零點，整個 $s$ 平面就確定了。

### 3.5 混疊與 Shannon 取樣定理（**必考觀念**）

**經典例子**（Fig. 3-9）：取 $\omega_1=\dfrac{\omega_s}{4}$，則 $\cos\omega_1t$ 與 $\cos3\omega_1t$ **在所有取樣瞬間值完全相同**。

**理由**：$j3\omega_1=j(-\omega_1+\omega_s)$，兩組極點相差恰好 $\omega_s$，由性質 2 產生相同的 $E^*(s)$。

**頻譜複製**（式 3-22）：取樣把原頻譜複製到 $\pm\omega_s,\pm2\omega_s,\dots$ 並全部疊加。

$$
\boxed{\textbf{Shannon 取樣定理：}\ \text{若 }e(t)\text{ 不含高於 }f_0\text{ Hz 的成分，則可由間隔 }\frac{1}{2f_0}\text{ 秒的取樣點唯一決定}}
$$

**混疊頻率**：真實頻率 $f_0$ 被 $f_s$ 取樣（$f_s<2f_0$）後，視在頻率為 $\lvert f_0-kf_s\rvert$ 落在 $[0,f_s/2]$ 的那一個。

**防治方法**：

| 方法 | 限制 |
|---|---|
| 提高取樣頻率 $\omega_s$ | 受硬體運算能力限制 |
| **防混疊濾波器**（取樣器**前面**的類比低通） | 低通會引入相位落後，截止頻率太低會**使系統不穩定** |

### 3.6 三種資料保持器（**必考**）

**統一觀點**：把 $e(t)$ 在 $t=nT$ 做泰勒展開，**差別只在取幾項**。導數用**後向差分**近似：

$$
e'(nT)=\frac{e(nT)-e[(n-1)T]}{T}
$$

| 保持器 | 取到第幾項 | 轉移函數 | 記憶體 |
|---|---|---|---|
| **ZOH** | 常數項 | $G_{h0}(s)=\dfrac{1-e^{-Ts}}{s}$ | 否 |
| **FOH** | 一次項 | $G_{h1}(s)=\dfrac{1+Ts}{T}\left[\dfrac{1-e^{-Ts}}{s}\right]^2$ | 是 |
| **分數階** | 一次項乘 $k$ | $G_{hk}(s)=(1-ke^{-Ts})\dfrac{1-e^{-Ts}}{s}+\dfrac{k}{Ts^2}(1-e^{-Ts})^2$ | 是 |

**分數階的兩個端點**：$k=0\to$ ZOH；$k=1\to$ FOH。

### 3.7 ZOH 的頻率響應（**必考推導**）

$$
G_{h0}(j\omega)=\frac{1-e^{-j\omega T}}{j\omega}\cdot\frac{e^{j\omega T/2}}{e^{j\omega T/2}}
=T\frac{\sin(\omega T/2)}{\omega T/2}e^{-j\omega T/2}
$$

因為 $\dfrac{\omega T}{2}=\dfrac{\pi\omega}{\omega_s}$：

$$
\boxed{\left\lvert G_{h0}(j\omega)\right\rvert=T\left\lvert\frac{\sin(\pi\omega/\omega_s)}{\pi\omega/\omega_s}\right\rvert,\qquad
\angle G_{h0}(j\omega)=-\frac{\pi\omega}{\omega_s}+\phi}
$$

其中 $\phi=0$（當 $\sin>0$）或 $\pi$（當 $\sin<0$）。

> **⚠️ 全章最重要的結論（幾乎必考）**
>
> $$\frac{\pi}{\omega_s}=\frac{\pi}{2\pi/T}=\frac{T}{2}\quad\Longrightarrow\quad e^{-j\pi\omega/\omega_s}=e^{-j\omega T/2}$$
>
> $$\boxed{\textbf{ZOH 在相位上等效於一個 }T/2\text{ 秒的純延遲}}$$
>
> 這是「$T$ 不能取太大」的**第二個理由**（第一個是 Shannon 定理）——延遲吃掉相位裕度，讓系統趨向不穩定。

**幾個要記的值**：

| $\omega$ | $\lvert G_{h0}\rvert$ |
|---|---|
| $\omega\to0$ | $T$（最大值） |
| $\omega=\omega_s/2$（Nyquist） | $\dfrac{2T}{\pi}\approx0.637T$ |
| $\omega=k\omega_s$（$k\ne0$） | $0$（sinc 的零點） |

**ZOH vs FOH**（教材結論）：

| 頻段 | 誰較接近理想低通 |
|---|---|
| 零頻率附近 | **FOH**（主要是**相位**優勢） |
| 較大的 $\omega$ | **ZOH** |

> **但實務上 ZOH 遠比 FOH 常用，理由是成本。**

---

## 4. 第四章：開迴路離散時間系統（**計算題主力**）

### 4.1 $E(z)$ 與 $E^*(s)$ 的橋樑（式 4-3）

$$
\boxed{E(z)=E^*(s)\Big\vert_{e^{sT}=z}}
$$

> **意義**：**z 轉換是拉氏轉換的一個特例**。第 2 章對 z 轉換證明的所有定理，全部自動適用於星號轉換——所以教科書不另列星號轉換表。

**為什麼要改用 $E(z)$**：

| | $E^*(s)$ | $E(z)$ |
|---|---|---|
| 極點數 | **無限多**（性質 2） | **有限個** |
| 極零點分析 | 幾乎無法用 | 可直接用 |

### 4.2 脈衝轉移函數（**全章核心**）

$$
C(s)=G(s)E^*(s)\ \xrightarrow{\ \text{式 3-11}\ }\ C^*(s)=\frac1T\sum_nG(s+jn\omega_s)E^*(s+jn\omega_s)
$$

**關鍵一步**：用性質 1 的週期性 $E^*(s+jn\omega_s)=E^*(s)$，把 $E^*(s)$ **提到求和外面**：

$$
C^*(s)=E^*(s)G^*(s)\quad\Longrightarrow\quad \boxed{C(z)=G(z)E(z)}
$$

> **⚠️ 根本限制（必考觀念題）**：
>
> **脈衝轉移函數只給出「取樣瞬間」的輸出，對取樣點之間的 $c(t)$ 一無所知。**
>
> 實務上：把取樣率選得夠高；真的需要完整響應時用**模擬**。

**常用等價寫法**（查表時很好用）：

$$
G(z)=\mathcal{Z}\left[\frac{1-e^{-Ts}}{s}G_p(s)\right]=\frac{z-1}{z}\,\mathcal{Z}\left[\frac{G_p(s)}{s}\right]
$$

### 4.3 直流增益檢查（式 4-14，**最實用的驗算**）

$$
\boxed{\text{dc gain}=\lim_{z\to1}G(z)=\lim_{s\to0}G_p(s)}
$$

> **考試技巧**：算完 $G(z)$ 花三秒代 $z=1$，跟 $G_p(s)$ 代 $s=0$ 比一比。**不相等就是算錯了。**

### 4.4 三種串聯組態（**必考，最容易錯**）

| 組態 | 圖 | 結果 |
|---|---|---|
| **(a) 中間有取樣器** | $E\to/\to G_1\to/\to G_2\to C$ | $C(z)=G_1(z)G_2(z)E(z)$ |
| **(b) 中間沒有取樣器** | $E\to/\to G_1\to G_2\to C$ | $C(z)=\overline{G_1G_2}(z)E(z)$ |
| **(c) 輸入先過連續部分才取樣** | $E\to G_1\to/\to G_2\to C$ | $C(z)=G_2(z)\overline{G_1E}(z)$，**無轉移函數** |

$$
\boxed{\overline{G_1G_2}(z)=\mathcal{Z}[G_1(s)G_2(s)]\ \neq\ G_1(z)G_2(z)}
$$

> **橫線的意思**：**必須先在 $s$ 域相乘，然後才取 z 轉換。**
>
> **為什麼不等**：兩者對應**物理上不同的系統**——組態 (a) 中間多了一個取樣器加保持器，訊號被「階梯化」了一次。**硬體不同，答案當然不同。**

**組態 (c) 為什麼寫不出轉移函數**：因為 $a(t)=\displaystyle\int_0^tg_1(t-\tau)e(\tau)d\tau$ 取決於 $e(t)$ **過去的所有值**，而不只是取樣瞬間的值，因此 $E(z)$ 無法從 $\overline{G_1E}(z)$ 中分離。

> **一般結論**：**若輸入先施加到連續部分再被取樣，輸出的 z 轉換無法表示成輸入 z 轉換的函數。**

### 4.5 含數位濾波器的系統（式 4-24）

$$
\boxed{C(z)=\mathcal{Z}\left[G_p(s)\frac{1-e^{-Ts}}{s}\right]D(z)E(z)=G(z)D(z)E(z)}
$$

**關鍵物理事實**：D/A 轉換器帶有**輸出資料保持暫存器**，因此具有**零階保持器的特性**。

> **完整模型必須是「理想取樣器 + $D(z)$ + 零階保持器」三者的組合**——因為實體電腦處理的是**數值**，而數學模型處理的是**脈衝序列**。

**例 4.4**：$m(kT)=2e(kT)-e[(k-1)T]\Rightarrow D(z)=2-z^{-1}=\dfrac{2z-1}{z}$

三重驗證（**很好的答題習慣**）：終值定理、dc 增益相乘、追蹤訊號。

### 4.6 修正 z 轉換與時間延遲（**必考**）

**延遲 z 轉換**（延遲 $\Delta T$，**取樣本身不延遲**）：

$$
E(z,\Delta)=\mathcal{Z}\left[e(t-\Delta T)u(t-\Delta T)\right]=\mathcal{Z}\left[E(s)e^{-\Delta Ts}\right]
$$

**修正 z 轉換**（令 $m=1-\Delta$）：

$$
\boxed{E(z,m)=E(z,\Delta)\Big\vert_{\Delta=1-m}=e(mT)z^{-1}+e[(1+m)T]z^{-2}+\cdots}
$$

> **💡 $m$ 的物理意義**：$m$ 是「**在每個取樣區間內往前推進的比例**」。**修正 z 轉換讓你看得到取樣點「之間」的響應**——正好補足 4.2 節指出的限制。

**兩個端點**：$E(z,1)=E(z)-e(0)$（無延遲）；$E(z,0)=z^{-1}E(z)$（延遲一整個週期）。

**含時間延遲的核心公式**：

$$
t_0=kT+\Delta T\ (0<\Delta<1,\ k\text{ 為正整數})
$$

$$
\boxed{C(z)=z^{-k}\,G(z,m)\,E(z),\qquad m=1-\Delta}
$$

| 部分 | 用什麼處理 | 變成 |
|---|---|---|
| 整數部分 $kT$ | 平移定理 | $z^{-k}$ |
| 零頭 $\Delta T$ | 修正 z 轉換 | $G(z,m)$ |

**實務應用**：**數位電腦的運算時間**。把控制器模型化為「無延遲控制器 + $t_0$ 秒理想延遲」串聯：

$$
C(z)=z^{-k}G(z,m)D(z)E(z)
$$

### 4.7 離散狀態方程式（**必考公式**）

**由連續狀態模型直接求離散模型**：

$$
\boxed{A=\Phi_c(T)=e^{A_cT},\qquad B=\left[\int_0^T\Phi_c(\nu)\,d\nu\right]B_c,\qquad C=C_c,\quad D=D_c}
$$

> **⚠️ 成立的前提（常考）**：推導中把 $\mathbf u$ 提到積分外面，**只有在 $\mathbf u(t)$ 是零階保持器的輸出時才成立**。

> **⚠️ 離散化只改變 $A$ 和 $B$，不改變 $C$ 和 $D$**——因為 $C$、$D$ 描述「量測關係」，與多久看一次無關。

**級數展開**（式 4-72、4-74）：

$$
\Phi_c(T)=I+A_cT+\frac{A_c^2T^2}{2!}+\frac{A_c^3T^3}{3!}+\cdots
$$

$$
B=\left[IT+\frac{A_cT^2}{2!}+\frac{A_c^2T^3}{3!}+\cdots\right]B_c
$$

> **教材數據**：**三位有效數字需 3 項，六位有效數字需 5 項。**

**由離散狀態模型求脈衝轉移函數**：

$$
\boxed{G(z)=C\left[zI-A\right]^{-1}B+D}
$$

### 4.8 例 4.13 完整計算（**極可能考的計算題**）

$G_p(s)=\dfrac{10}{s(s+1)}$，$T=0.1$ s。

**連續狀態模型**：

$$
A_c=\begin{bmatrix}0&1\cr0&-1\end{bmatrix},\quad B_c=\begin{bmatrix}0\cr10\end{bmatrix},\quad C_c=\begin{bmatrix}1&0\end{bmatrix}
$$

**求狀態轉移矩陣**：

$$
\Phi_c(t)=\mathcal{L}^{-1}\left[(sI-A_c)^{-1}\right]
=\mathcal{L}^{-1}\begin{bmatrix}\frac1s&\frac{1}{s(s+1)}\cr0&\frac{1}{s+1}\end{bmatrix}
=\begin{bmatrix}1&1-e^{-t}\cr0&e^{-t}\end{bmatrix}
$$

**積分**：

$$
\int_0^T\Phi_c(\nu)d\nu=\begin{bmatrix}\nu&\nu+e^{-\nu}\cr0&-e^{-\nu}\end{bmatrix}_0^T=\begin{bmatrix}T&T-1+e^{-T}\cr0&1-e^{-T}\end{bmatrix}
$$

**代入 $T=0.1$**：

$$
\boxed{A=\begin{bmatrix}1&0.0952\cr0&0.905\end{bmatrix},\qquad
B=\begin{bmatrix}0.1&0.00484\cr0&0.0952\end{bmatrix}\begin{bmatrix}0\cr10\end{bmatrix}=\begin{bmatrix}0.0484\cr0.952\end{bmatrix}}
$$

> **💡 教材的重要觀察**：類比受控體的模擬圖與離散模型的模擬圖，**雖然狀態、輸入、輸出在取樣瞬間完全相等，兩張圖卻長得完全不像**。

---

## 5. 一頁公式速查表

### 第 2 章

| 公式 | 內容 |
|---|---|
| z 轉換定義 | $E(z)=\sum_{k=0}^{\infty}e(k)z^{-k}$ |
| 延遲 | $\mathcal{Z}[e(k-n)u(k-n)]=z^{-n}E(z)$ |
| 超前 | $\mathcal{Z}[e(k+n)u(k)]=z^n\left[E(z)-\sum_{k=0}^{n-1}e(k)z^{-k}\right]$ |
| 初值／終值 | $e(0)=\lim_{z\to\infty}E(z)$；$e(\infty)=\lim_{z\to1}(z-1)E(z)$ |
| 反 z 轉換關鍵 | **先展開 $E(z)/z$** |
| 轉移函數 | $G(z)=C[zI-A]^{-1}B+D$ |
| 狀態解 | $\mathbf x(k)=A^k\mathbf x(0)+\sum_{j=0}^{k-1}A^{k-1-j}B\mathbf u(j)$ |
| 狀態轉移矩陣 | $\Phi(k)=A^k=\mathcal{Z}^{-1}\left[(zI-A)^{-1}z\right]$ |
| 相似轉換 | $A_w=P^{-1}AP$，**特徵值不變** |

### 第 3 章

| 公式 | 內容 |
|---|---|
| 取樣–保持分解 | $\bar E(s)=E^*(s)\cdot\dfrac{1-e^{-Ts}}{s}$ |
| 星號轉換 | $E^*(s)=\sum_{n=0}^{\infty}e(nT)e^{-nTs}$ |
| ZOH | $G_{h0}(s)=\dfrac{1-e^{-Ts}}{s}$ |
| 性質 1 | $E^*(s+jm\omega_s)=E^*(s)$ |
| 頻譜複製 | $E^*(s)=\dfrac1T\sum_nE(s+jn\omega_s)+\dfrac{e(0)}2$ |
| ZOH 振幅 | $T\left\lvert\mathrm{sinc}\left(\dfrac{\pi\omega}{\omega_s}\right)\right\rvert$ |
| **ZOH 等效延遲** | $\boxed{T/2}$ |
| FOH | $G_{h1}(s)=\dfrac{1+Ts}{T}\left[\dfrac{1-e^{-Ts}}{s}\right]^2$ |
| Shannon | $\omega_s>2\omega_{\max}$ |

### 第 4 章

| 公式 | 內容 |
|---|---|
| 橋樑 | $E(z)=E^*(s)\big\vert_{e^{sT}=z}$ |
| **脈衝轉移函數** | $C(z)=G(z)E(z)$ |
| **dc 增益檢查** | $\lim_{z\to1}G(z)=\lim_{s\to0}G_p(s)$ |
| 查表捷徑 | $G(z)=\dfrac{z-1}{z}\mathcal{Z}\left[\dfrac{G_p(s)}{s}\right]$ |
| **最易錯** | $\overline{G_1G_2}(z)\neq G_1(z)G_2(z)$ |
| 數位濾波器 | $C(z)=G(z)D(z)E(z)$ |
| 修正 z 轉換 | $E(z,m)=E(z,\Delta)\big\vert_{\Delta=1-m}$ |
| 時間延遲 | $C(z)=z^{-k}G(z,m)E(z)$，$t_0=kT+\Delta T$ |
| **離散化** | $A=e^{A_cT}$，$B=\left[\int_0^T\Phi_c(\nu)d\nu\right]B_c$，$C=C_c$，$D=D_c$ |
| 求 $G(z)$ | $G(z)=C[zI-A]^{-1}B+D$ |

---

## 6. 常考題型與解題步驟

### 題型 A：由 $E(s)$ 求 $E(z)$

1. 分母因式分解
2. **部分分式展開**（留數法 $K_i=(s-p_i)E(s)\big|_{s=p_i}$）
3. 逐項套 $\dfrac{1}{s+a}\to\dfrac{z}{z-e^{-aT}}$
4. **驗算**：$z\to\infty$ 應等於 $e(0)$

### 題型 B：反 z 轉換求 $e(k)$

1. **先寫 $\dfrac{E(z)}{z}$**（最重要的一步）
2. 部分分式展開
3. 兩邊乘回 $z$
4. 查表得 $e(k)$
5. **驗算**：算 $e(0),e(1)$ 與長除法前兩項比對

### 題型 C：求脈衝轉移函數 $G(z)$

1. 認清方塊圖：**取樣器在哪裡？** 決定用 $G_1(z)G_2(z)$ 還是 $\overline{G_1G_2}(z)$
2. 用捷徑 $G(z)=\dfrac{z-1}{z}\mathcal{Z}\left[\dfrac{G_p(s)}{s}\right]$
3. 查表、通分、化簡
4. **驗算**：dc 增益 $G(1)$ 對不對

### 題型 D：連續模型離散化

1. 由 $G_p(s)$ 或物理方程式寫出 $A_c,B_c,C_c,D_c$
2. 求 $\Phi_c(t)=\mathcal{L}^{-1}\left[(sI-A_c)^{-1}\right]$
3. $A=\Phi_c(T)$
4. $B=\left[\int_0^T\Phi_c(\nu)d\nu\right]B_c$
5. $C=C_c$，$D=D_c$（**不變**）
6. 若要 $G(z)$：$G(z)=C[zI-A]^{-1}B+D$
7. **驗算**：dc 增益

### 題型 E：狀態方程式求解

1. 求 $\Phi(k)=A^k$（用 $\mathcal{Z}^{-1}\left[(zI-A)^{-1}z\right]$ 或對角化 $A^k=P\Lambda^kP^{-1}$）
2. 零輸入項 $A^k\mathbf x(0)$
3. 零狀態項 $\sum_{j=0}^{k-1}A^{k-1-j}B\mathbf u(j)$
4. **驗算**：$k=0$ 應得 $\mathbf x(0)$

### 題型 F：觀念問答（送分題，一定要拿到）

**常見題目與標準答案**：

| 題目 | 答案要點 |
|---|---|
| 為什麼取樣器沒有轉移函數？ | 多個不同輸入可產生相同 $E^*(s)$（多對一），轉移函數要求一對一 |
| $E^*(s)$ 是實體訊號嗎？ | **不是**，是式 (3-2) 因式分解的中間量；但「取樣器 + 保持器」串聯確實描述實體裝置 |
| 為什麼要資料保持器？ | 脈衝串含大量高頻成分，直接餵受控體會激發不想要的動態 |
| 為什麼 ZOH 最常用？ | **不需要記憶體，最容易製作，成本最低** |
| ZOH 對穩定度的影響？ | 等效引入 **$T/2$ 的純延遲**，吃掉相位裕度 |
| 什麼是混疊？怎麼防？ | 高於 $\omega_s/2$ 的頻率摺返成低頻；提高 $\omega_s$ 或加**防混疊濾波器**（但截止頻率不能太低，會使系統不穩定） |
| $\overline{G_1G_2}(z)$ 與 $G_1(z)G_2(z)$ 為何不同？ | 對應**物理上不同的系統**——中間有無取樣器（是否被階梯化） |
| 脈衝轉移函數的限制？ | **只給取樣瞬間的輸出**，取樣點之間一無所知 |
| 離散化為何 $C$、$D$ 不變？ | 它們描述**量測關係**，與取樣頻率無關 |
| 離散化公式的前提？ | **輸入必須是零階保持器的輸出**（$\mathbf u$ 在區間內為常數才能提出積分） |

---

## 7. 易錯陷阱總整理

| # | 陷阱 | 正確做法 |
|---|---|---|
| 1 | 反 z 轉換直接展開 $E(z)$ | **先展開 $E(z)/z$**，最後乘回 $z$ |
| 2 | 超前定理忘記扣初始項 | $\mathcal{Z}[e(k+n)u(k)]=z^n\left[E(z)-\sum_{k=0}^{n-1}e(k)z^{-k}\right]$ |
| 3 | 終值定理亂用 | 極點須在單位圓內，$z=1$ 最多一個單重極點 |
| 4 | $\overline{G_1G_2}(z)$ 寫成 $G_1(z)G_2(z)$ | 看方塊圖**中間有沒有取樣器** |
| 5 | 忘記 $G(s)$ 已含保持器 | 題目畫成 $E\to/\to G(s)\to C$ 時，$G(s)$ **必定含 ZOH** |
| 6 | 離散化時也改了 $C$、$D$ | **只有 $A$、$B$ 會變** |
| 7 | 以為 $A=e^{A_cT}$ 是逐元素指數 | 是**矩陣指數**（級數定義），不是對每個元素取 $e^x$ |
| 8 | 相似轉換後以為極點變了 | **特徵值不變** |
| 9 | 混淆 $\Delta$ 與 $m$ | $m=1-\Delta$；$m=1$ 無延遲，$m=0$ 延遲一整週期 |
| 10 | 忘記 $\omega_s=2\pi/T$ 不是 $1/T$ | 角頻率要乘 $2\pi$ |
| 11 | 把 ZOH 輸出畫成折線 | 是**階梯**（每個區間保持常數） |
| 12 | Nyquist 頻率寫成 $\omega_s$ | 是 **$\omega_s/2$** |

---

## 8. 考前一天檢查清單

**能不能不看書就寫出**：

- [ ] z 轉換定義、延遲／超前定理（含初始項）
- [ ] 初值與終值定理**及其成立條件**
- [ ] z 轉換表前 6 項（$\delta$、$1$、$k$、$a^k$、$ka^k$、$\sin/\cos$）
- [ ] 反 z 轉換四種方法的名稱與優缺點
- [ ] $G(z)=C[zI-A]^{-1}B+D$
- [ ] $\mathbf x(k)=A^k\mathbf x(0)+\sum A^{k-1-j}B\mathbf u(j)$
- [ ] 式 (3-2) 的取樣–保持分解圖
- [ ] $G_{h0}(s)=\dfrac{1-e^{-Ts}}{s}$ 與 **ZOH 等效 $T/2$ 延遲**
- [ ] Shannon 取樣定理與混疊的成因
- [ ] $C(z)=G(z)E(z)$ 與其**限制**
- [ ] $\overline{G_1G_2}(z)\neq G_1(z)G_2(z)$ 與**物理理由**
- [ ] dc 增益檢查 $\lim_{z\to1}G(z)=\lim_{s\to0}G_p(s)$
- [ ] $A=e^{A_cT}$、$B=\left[\int_0^T\Phi_c d\nu\right]B_c$、$C=C_c$、$D=D_c$
- [ ] 修正 z 轉換與 $C(z)=z^{-k}G(z,m)E(z)$
- [ ] 四大建模範例的轉移函數

**動手練過**：

- [ ] 由 $E(s)$ 求 $E(z)$（部分分式）至少 3 題
- [ ] 反 z 轉換（部分分式法）至少 3 題
- [ ] 求 $G(z)=\mathcal{Z}\left[\frac{1-e^{-Ts}}{s}G_p(s)\right]$ 至少 3 題
- [ ] 例 4.13 的離散化計算（手算 $\Phi_c(t)$ 與積分）
- [ ] $\Phi(k)=A^k$ 的兩種求法各一題

---

## 附錄：本複習講義對應的完整筆記

| 章 | 詳細筆記 | 可執行程式 | 逐格教學 |
|---|---|---|---|
| Ch. 1 | `course/CHP1/chp1.md` | `chp1.m` | `chp1.ipynb` |
| Ch. 2 | `course/CHP2/chp2.md` | `chp2.m` | `chp2.ipynb` |
| Ch. 3 | `course/CHP3/chp3.md` | `chp3.m` | `chp3.ipynb` |
| Ch. 4 | `course/CHP4/chp4.md` | `chp4.m` | `chp4.ipynb` |

**祝考試順利。**
