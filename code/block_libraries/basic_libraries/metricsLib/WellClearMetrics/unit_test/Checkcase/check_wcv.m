function wcv_bool = check_wcv(x1, x2, y1, y2, ...
    h1, h2, dx1, dx2, dy1, dy2, dh1, dh2, ...
    modT_thr, DMOD_thr, HMD_thr, TCOA_thr, h_thr)
%
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11

%East
dX = x2 - x1;
%North
dY = y2 - y1;
%Up
dZ = h2 - h1;

%East rate
vrX = dx2 - dx1;
%North Rate
vrY = dy2 - dy1;
%Up Rate
vrZ = dh2 - dh1;

%Range
R = hypot(dX, dY);
%Compure relative bearing angle
psi_rel = atan2(dY, dX);  % Relative angle from 1-0
%Range Rate
RR = vrX .* cos(psi_rel) + vrY .* sin(psi_rel);

tmpT = (DMOD_thr^2 - R.^2) ./ (R.*RR);
tmpT((R>=0) & (R<=DMOD_thr)) = 0;
tmpT(tmpT < 0) = inf;
modT = tmpT;

%Establish TCOA
TCOA = dZ ./ -vrZ;
TCOA(TCOA < 0) = inf;

%Establish Horizontal Miss Distance                    
t = -(((x2-x1) .* (dx2-dx1) + (dy2-dy1) .* (y2-y1)) ./ ((dy2-dy1).^2 + (dx2-dx1).^2));

HMD = sqrt(((x2 + dx2 .* t) - (x1 + dx1 .* t)).^2 + ((y2 + dy2 .* t) - (y1 + dy1 .* t)).^2);
HMD(t < 0) = -inf;

%Determine whether horizontal and vertical well clear are violated
wcvh = (0 <= modT & modT <= modT_thr & HMD <= HMD_thr);
wcvz = abs(dZ) <= h_thr | (0 <= TCOA & TCOA <= TCOA_thr);

%If both are violated, return true, otherwise false
wcv_bool = wcvh & wcvz;

end