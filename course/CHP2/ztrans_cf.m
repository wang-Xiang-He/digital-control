function [F, roc] = ztrans_cf (f, varargin)
%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @deftypefn  {} {@var{F} =} ztrans_cf (@var{f})
%% @deftypefnx {} {@var{F} =} ztrans_cf (@var{f}, @var{z})
%% @deftypefnx {} {@var{F} =} ztrans_cf (@var{f}, @var{k}, @var{z})
%% @deftypefnx {} {[@var{F}, @var{roc}] =} ztrans_cf (@dots{})
%% z 轉換，強制求出收斂域內的閉合形式（cf = closed form）。
%%
%% symbolic 套件的 @code{ztrans} 直接把定義式丟給 SymPy 求和，遇到
%% @code{exp(-a*k*T)}、@code{a^(k*T)*cos(b*k*T)} 這類底數未知正負大小的項，
%% SymPy 無法判斷 @code{|底數/z| < 1} 是否成立，就會原封不動回傳未求和的
%% @code{Sum}。這個問題無法用 @code{assume} 解決，因為收斂條件是「兩個自由
%% 符號之間的不等式」，不在 SymPy 假設系統的表達能力內。
%%
%% 這裡改用替換法：把每個 @code{底數^(c*k)} 的底數換成單一啞符號 @code{q}，
%% SymPy 對 @code{Sum(q^k*z^-k)} 有現成的幾何級數公式，會回傳一個 Piecewise；
%% 取其收斂支後在 q 空間化簡，再把 q 代回。
%%
%% 等於是「宣告自己位在收斂域（ROC）內」，與課本 z 轉換表的前提相同。
%%
%% ⚠ 本函式並不驗證收斂，它是「假設」收斂。要第二個回傳值 @var{roc}
%% 才會告訴你它假設了什麼條件——那正是這個結果成立的收斂域。
%%
%% @example
%% @group
%% syms a b k T z
%% ztrans_cf (exp(-a*k*T), k, z)
%%   @result{} (sym) z/(z - exp(-T*a))
%% ztrans_cf (a^(k*T)*cos(b*k*T), k, z)
%%   @result{} (sym) z*(z - a^T*cos(T*b))/(z^2 - 2*a^T*z*cos(T*b) + a^(2*T))
%% [F, roc] = ztrans_cf (exp(-a*k*T), k, z)
%%   @result{} roc = (sym) exp(-T*a)/Abs(z) < 1      %% 即 |z| > |exp(-a*T)|
%% @end group
%% @end example
%%
%% @seealso{ztrans, iztrans}
%% @end deftypefn

  if (nargin < 1 || nargin > 3)
    print_usage ();
  end

  f = sym (f);

  switch (nargin)
    case 1
      k = indep_var (f);
      z = out_var (f);
    case 2
      k = indep_var (f);
      z = sym (varargin{1});
    case 3
      k = sym (varargin{1});
      z = sym (varargin{2});
  end

  % 註：下面的字串陣列是要交給 SymPy 執行的 Python 程式碼。
  %     裡面不要放中文註解，pycall_sympy__ 會處理不了。
  %
  %  Heaviside 那行：ilaplace 回傳的項都帶 Heaviside(t)，代入 t=k*T 後會讓化簡
  %           爆掉。z 轉換本來就從 k=0 開始加，訊號必為因果，直接視為 1。
  %  三角那行：只把三角函數改寫成指數。若對整式做 rewrite(exp)，a**(T*k) 會被
  %           拆成 exp(T*k*log(a))，最後收不回 a**T，會跑出一堆 sinh/cosh。
  %  _match/_rep：把每個「底數^(c*k)」的底數換成啞符號 q，讓 SymPy 算得動。
  %  Piecewise 那行：取收斂支，等同宣告我們位在 ROC 內。
  %  simplify 順序：先在 q 空間化簡再代回，反過來結果會很醜。
  code = {
  'f = _ins[0]; kk = _ins[1]; zz = _ins[2]'
  'f = f.replace(sp.Heaviside, lambda *a: sp.Integer(1))'
  'f = f.replace(lambda e: e.func in (sp.cos, sp.sin), lambda e: e.rewrite(sp.exp))'
  'back = {}'
  'def _match(e):'
  '    return (e.is_Pow or e.func == sp.exp) and e.as_base_exp()[1].has(kk)'
  'def _rep(e):'
  '    bb, ex = e.as_base_exp()'
  '    c = sp.cancel(sp.expand(ex)/kk)'
  '    if c.has(kk) or c == 0:'
  '        return e'
  '    d = sp.Dummy("q%d" % len(back))'
  '    back[d] = sp.powsimp(bb**c)'
  '    return d**kk'
  'g = sp.expand(f).replace(_match, _rep)'
  'S = sp.summation(sp.powsimp(sp.expand(g)*zz**(-kk)), (kk, 0, sp.oo))'
  'conds = []'
  'def _pick(e):'
  '    conds.append(e.args[0][1])'
  '    return e.args[0][0]'
  'S = S.replace(lambda e: isinstance(e, sp.Piecewise), _pick)'
  'S = sp.simplify(sp.cancel(sp.together(S)))'
  'S = sp.powsimp(S.subs(back), force=True)'
  'if conds:'
  '    roc = sp.And(*[sp.powsimp(c.subs(back), force=True) for c in conds])'
  '    roc = sp.simplify(roc)'
  'else:'
  '    roc = sp.true'
  'return sp.simplify(S.rewrite(sp.cos)), roc'};

  [F, roc] = pycall_sympy__ (code, f, k, z);

end


function k = indep_var (f)
%% 時間索引：優先 k，再來 n，都沒有就取 symvar 第一個。
  v = symvar (f);
  for want = {'k', 'n'}
    for i = 1:numel (v)
      if (strcmp (char (v(i)), want{1}))
        k = v(i);
        return
      end
    end
  end
  if (isempty (v))
    k = sym ('k');
  else
    k = symvar (f, 1);
  end
end


function z = out_var (f)
%% 輸出變數預設 z；若 f 本身已含 z（會撞名）則改用 w。
  v = symvar (f);
  for i = 1:numel (v)
    if (strcmp (char (v(i)), 'z'))
      z = sym ('w');
      return
    end
  end
  z = sym ('z');
end


%!test
%! % 單位步階：Z{1} = z/(z-1)
%! syms k z
%! assert (isequal (simplify (ztrans_cf (sym(1)^k, k, z) - z/(z-1)), sym (0)))

%!test
%! % 指數：Z{exp(-a*k*T)} = z/(z - exp(-a*T))
%! syms a k T z
%! assert (isequal (simplify (ztrans_cf (exp(-a*k*T), k, z) - z/(z-exp(-a*T))), sym (0)))

%!test
%! % 複數平移：Z{k*T*exp(a*k*T)} = T*z*exp(a*T)/(z-exp(a*T))^2
%! syms a k T z
%! got = ztrans_cf ((k*T)*exp(a*k*T), k, z);
%! want = T*z*exp(a*T)/(z-exp(a*T))^2;
%! assert (isequal (simplify (got - want), sym (0)))

%!test
%! % 阻尼餘弦（課本表）
%! syms a b k T z
%! got = ztrans_cf (a^(k*T)*cos(b*k*T), k, z);
%! want = z*(z - a^T*cos(b*T)) / (z^2 - 2*a^T*z*cos(b*T) + a^(2*T));
%! assert (isequal (simplify (got - want), sym (0)))

%!test
%! % 阻尼正弦（課本表）
%! syms a b k T z
%! got = ztrans_cf (a^(k*T)*sin(b*k*T), k, z);
%! want = a^T*z*sin(b*T) / (z^2 - 2*a^T*z*cos(b*T) + a^(2*T));
%! assert (isequal (simplify (got - want), sym (0)))

%!test
%! % 省略引數：自動偵測 k 為時間索引、輸出用 z
%! syms a k T
%! assert (isequal (simplify (ztrans_cf (exp(-a*k*T)) - sym('z')/(sym('z')-exp(-a*T))), sym (0)))

%!error <Invalid call> ztrans_cf ()

%!test
%! % ilaplace 的輸出帶 Heaviside(t)，代入 t=k*T 後必須先剝掉才化簡得動
%! syms s t k z
%! Ts = sym(1)/10;
%! et = ilaplace((s^2+4*s+3)/(s^3+6*s^2+8*s), s, t);
%! F  = ztrans_cf (subs (et, t, k*Ts), k, z);
%! [na, da] = numden (F);
%! ca = double (coeffs (expand (na), z, 'all'));  ca = ca / ca(1);
%! cb = double (coeffs (expand (da), z, 'all'));  cb = cb / cb(1);
%! assert (ca, [1, -1.658, 0.6804, 0], 1e-3)
%! assert (cb, [1, -2.489, 2.038, -0.5488], 1e-3)
