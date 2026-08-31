function f = iztrans (F, varargin)
%% -*- texinfo -*-
%% @documentencoding UTF-8
%% @deftypefn  {} {@var{f} =} iztrans (@var{F})
%% @deftypefnx {} {@var{f} =} iztrans (@var{F}, @var{k})
%% @deftypefnx {} {@var{f} =} iztrans (@var{F}, @var{z}, @var{k})
%% 反 z 轉換（inverse z-transform）。
%%
%% Octave 的 symbolic 套件提供了 @code{ztrans}，卻沒有實作對應的反轉換
%% （到 3.2.2 為止都沒有），因此這裡自己補上。用留數法：
%%
%% @example
%%   e(k) = sum over all poles p of  Res[ E(z)*z^(k-1), z = p ]
%% @end example
%%
%% 對有理的 E(z) 有效；單根、重根、共軛複根皆可。
%% 引數慣例與 MATLAB Symbolic Math Toolbox 相同：
%% @var{z} 省略時取 F 的自變數（優先用 z），@var{k} 省略時用 n。
%%
%% @example
%% @group
%% syms z k
%% iztrans (z/((z-1)*(z-2)), k)
%%   @result{} (sym) 2^k - 1
%% iztrans (z/(z-1)^2, k)
%%   @result{} (sym) k
%% @end group
%% @end example
%%
%% @seealso{ztrans, ilaplace, ifourier}
%% @end deftypefn

  if (nargin < 1 || nargin > 3)
    print_usage ();
  end

  F = sym (F);

  switch (nargin)
    case 1
      z = default_var (F);
      k = sym ('n');
    case 2
      z = default_var (F);
      k = sym (varargin{1});
    case 3
      z = sym (varargin{1});
      k = sym (varargin{2});
  end

  code = {
  'F = _ins[0]; zz = _ins[1]; kk = _ins[2]'
  'F = sp.cancel(sp.together(sp.simplify(F)))'
  'den = sp.denom(F)'
  'if not den.has(zz):'
  '    raise ValueError("iztrans: F must be a rational function of the given variable")'
  'poles = sp.roots(sp.Poly(den, zz))'
  'expr = F*zz**(kk-1)'
  'tot = 0'
  'for p in poles:'
  '    tot += sp.residue(expr, zz, p)'
  'return sp.simplify(sp.expand(tot)),'};

  f = pycall_sympy__ (code, F, z, k);

end


function z = default_var (F)
%% 沒指定自變數時：優先用 z，否則退回 symvar 的第一個。
  v = symvar (F);
  z = sym ('z');
  if (isempty (v))
    return
  end
  for i = 1:numel (v)
    if (strcmp (char (v(i)), 'z'))
      return
    end
  end
  z = symvar (F, 1);
end


%!test
%! % 兩引數形式（MATLAB 慣例，chp2.m 用的就是這個）
%! syms z k
%! assert (isequal (iztrans (z/((z-1)*(z-2)), k), 2^k - 1))

%!test
%! % 重根
%! syms z k
%! assert (isequal (iztrans (z/(z-1)^2, k), k))

%!test
%! % 三引數形式
%! syms z k
%! assert (isequal (iztrans (z/(z-1), z, k), sym (1)))

%!test
%! % 非 z 的自變數，靠 symvar 偵測
%! syms w k
%! assert (isequal (iztrans (w/(w-3), k), sym (3)^k))

%!test
%! % 共軛複根：z/(z^2+1) -> sin(pi*k/2)，即數列 0,1,0,-1,0,1,...
%! % SymPy 不會自動化成三角形式，所以逐點比對數值。
%! syms z k
%! f = iztrans (z/(z^2+1), k);
%! for n = 0:5
%!   assert (double (simplify (subs (f, k, n))), sin (pi*n/2), 1e-12)
%! end

%!error <Invalid call> iztrans ()
