function s = to_latex (x, digits)
%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @deftypefn  {} {@var{s} =} to_latex (@var{x})
%% @deftypefnx {} {@var{s} =} to_latex (@var{x}, @var{digits})
%% 把符號運算式、數值矩陣或轉移函數轉成 LaTeX 字串。
%%
%% symbolic 套件的 @code{latex()} 只吃 @code{sym} 物件。這個函式補上另外
%% 兩種在本章會用到的型別，讓 @code{%sym} magic 對整份 Notebook 都適用：
%%
%% @table @asis
%% @item @code{sym}
%% 直接呼叫 @code{latex()}。
%% @item 數值（矩陣／向量／純量，可為複數）
%% 轉成 @code{sym} 再取 LaTeX。全部是整數就保持精確，否則用
%% @code{vpa} 顯示小數 —— 否則 @code{sym(1.35)} 會變成 @code{27/20}。
%% @item @code{lti}（@code{tf}、@code{ss} 等 control 套件的模型）
%% 用 @code{tfdata} 取出分子分母，再用 @code{poly2sym} 組成有理式。
%% 連續時間用 @code{s}，離散時間用 @code{z}。
%% @end table
%%
%% @var{digits} 為有效位數，預設 5。
%%
%% @example
%% @group
%% to_latex (sym('z')/(sym('z')-1))
%%   @result{} \frac{z}{z - 1}
%% to_latex ([1.35 0.55; -0.45 0.35])
%%   @result{} \left[\begin@{matrix@}1.35 & 0.55\-0.45 & 0.35\end@{matrix@}\right]
%% to_latex (tf([1 4 3],[1 6 8 0]))
%%   @result{} \frac{s^{2} + 4 s + 3}{s^{3} + 6 s^{2} + 8 s}
%% @end group
%% @end example
%%
%% @seealso{latex, ztrans_cf, iztrans}
%% @end deftypefn

  if (nargin < 1 || nargin > 2)
    print_usage ();
  end
  if (nargin < 2)
    digits = 5;
  end

  if (isa (x, 'sym'))
    s = latex (x);
    return
  end

  if (isa (x, 'lti'))
    [nu, de] = tfdata (x, 'v');
    if (x.Ts == 0)
      v = sym ('s');          % 連續時間
    else
      v = sym ('z');          % 離散時間
    end
    %% poly2sym 對浮點係數也會發「dangerous」警告，同樣是顯示用途，暫時關掉
    old = warning ('off', 'all');
    unwind_protect
      e = poly2sym (nu, v) / poly2sym (de, v);
      if (! all_int ([nu(:); de(:)]))
        e = vpa (e, digits);
      end
    unwind_protect_cleanup
      warning (old);
    end_unwind_protect
    s = tidy_tex (latex (e));
    return
  end

  if (isnumeric (x) || islogical (x))
    x = full (double (x));    % 對角矩陣、logical 都先攤平成一般 double
    %% sym() 對浮點數會發「dangerous」警告，這裡是顯示用途，暫時關掉
    old = warning ('off', 'all');
    unwind_protect
      y = sym (x);
      if (! all_int (x))
        y = vpa (y, digits);
      end
    unwind_protect_cleanup
      warning (old);
    end_unwind_protect
    s = tidy_tex (latex (y));
    return
  end

  error ('to_latex: 不支援的型別 ''%s''', class (x));

end


function s = tidy_tex (s)
%% vpa 會把整數也印成 1.0 / -2.0，矩陣裡混著小數時看起來很雜。
%% 這裡把「數字後面緊接 .0 且後面不是數字」的情形去掉小數點。
%% 用 lookahead 確保不會誤傷 1.05 或 10^{-16}。
  s = regexprep (s, '(\d)\.0(?![0-9])', '$1');
end


function b = all_int (v)
%% 是否全部為整數（複數時 fix 會對實部虛部各自取整）
  v = double (v(:));
  b = all (isfinite (v)) && all (v == fix (v));
end


%!test
%! % sym 直接走 latex()
%! syms z
%! assert (strcmp (to_latex (z/(z-1)), '\frac{z}{z - 1}'))

%!test
%! % 整數矩陣保持精確，不要變成 1.0
%! s = to_latex ([1 2; 3 4]);
%! assert (isempty (strfind (s, '.')))

%!test
%! % 非整數矩陣用小數，不要變成 27/20 這種分數
%! s = to_latex ([1.35 0.55; -0.45 0.35]);
%! assert (! isempty (strfind (s, '1.35')))
%! assert (isempty (strfind (s, 'frac')))

%!test
%! % 複數向量
%! s = to_latex ([2.5i; -2.5i]);
%! assert (! isempty (strfind (s, 'i')))

%!test
%! % 連續時間 tf -> 以 s 表示
%! s = to_latex (tf ([1 4 3], [1 6 8 0]));
%! assert (! isempty (strfind (s, 's^{3}')))

%!test
%! % 離散時間 tf -> 以 z 表示
%! s = to_latex (tf ([1 -0.5], [1 -0.2], 0.1));
%! assert (! isempty (strfind (s, 'z')))
%! assert (isempty (strfind (s, 's^')))

%!error <Invalid call> to_latex ()

%!test
%! % 矩陣裡混著小數時，vpa 會把整數也印成 1.0 / -2.0，應該清掉
%! s = to_latex ([0 1 0; 0 0 1; -0.5 -1 -2]);
%! assert (isempty (strfind (s, '1.0 ')))
%! assert (! isempty (strfind (s, '-0.5')))

%!test
%! % 但不可誤傷 1.05 這種真小數，也不可誤傷科學記號
%! assert (! isempty (strfind (to_latex ([1.05 2.5]), '1.05')))
%! assert (! isempty (strfind (to_latex ([0 -1.1102e-16]), '10^{-16}')))

