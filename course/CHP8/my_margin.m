function [gm_db, pm_deg, wg, wp] = my_margin(L, T)
%MY_MARGIN  自己掃頻計算增益／相位裕度
%
%   [gm_db, pm_deg, wg, wp] = my_margin(L, T)
%
%   為什麼不直接用 margin()：
%     Octave 的 margin 對本章補償後的系統常回傳 pm = 180、wp = NaN。
%     此外 bode 對含 z=1 極點的離散系統相位是錯的（見 chp7.m 附錄）。
%     這裡直接代 z = exp(j*w*T) 計算，並用 unwrap 展開相位。

    [nL, dL] = tfdata(L, 'v');
    wv = logspace(-4, log10(pi/T), 300000);
    Lv = polyval(nL, exp(1j*wv*T)) ./ polyval(dL, exp(1j*wv*T));
    mag = abs(Lv);
    ph  = unwrap(angle(Lv))*180/pi;

    i = find(mag(1:end-1) >= 1 & mag(2:end) < 1, 1);        % 增益交越（|L| 穿過 1）
    j = find(ph(1:end-1) >= -180 & ph(2:end) < -180, 1);    % 相位交越（相位穿過 -180）

    if isempty(i), pm_deg = NaN; wp = NaN; else pm_deg = 180 + ph(i); wp = wv(i); end
    if isempty(j), gm_db = Inf;  wg = NaN; else gm_db = -20*log10(mag(j)); wg = wv(j); end
end
