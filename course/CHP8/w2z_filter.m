function Dz = w2z_filter(a0, ww0, wwp, T)
%W2Z_FILTER  把 w 平面的一階補償器轉成 D(z)（教材式 8-14、8-15）
%
%   Dz = w2z_filter(a0, ww0, wwp, T)
%
%   a0  : 補償器直流增益
%   ww0 : 零點在 w 平面的位置
%   wwp : 極點在 w 平面的位置
%   T   : 取樣週期
%
%   D(w) = a0*(1 + w/ww0)/(1 + w/wwp)  ->  D(z) = Kd*(z-z0)/(z-zp)
%
%   ww0 < wwp -> 相位超前；ww0 > wwp -> 相位落後

    Kd = a0*(wwp*(ww0 + 2/T))/(ww0*(wwp + 2/T));   % 式 (8-15)
    z0 = (2/T - ww0)/(2/T + ww0);
    zp = (2/T - wwp)/(2/T + wwp);
    Dz = Kd*tf([1 -z0], [1 -zp], T);
end
