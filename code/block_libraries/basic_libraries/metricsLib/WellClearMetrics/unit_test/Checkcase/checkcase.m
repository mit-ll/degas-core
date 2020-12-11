function wcv = checkcase(data)
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%

% Setup ownship and intruder trajectories.
x_E1  = data(:, 1);
x_E2  = data(:, 2);
x_N1  = data(:, 3);
x_N2  = data(:, 4);
h1    = data(:, 5);
h2    = data(:, 6);
v_E1  = data(:, 7);
v_E2  = data(:, 8);
v_N1  = data(:, 9);
v_N2  = data(:,10);
hdot1 = data(:,11);
hdot2 = data(:,12);

%Tau Mod Threshold
modT_thr = 35;
%Distance threshold
D_thr = 4000;
%Time of Closest Approach Threshold
TCOA_thr = 0;
%Altitude Threshold
h_thr = 700;

%Determine if a well clear violation occurred
wcv = check_wcv(x_E1, x_E2, x_N1, x_N2, h1, h2,...
    v_E1, v_E2, v_N1, v_N2, hdot1, hdot2,...
    modT_thr, D_thr, D_thr, TCOA_thr, h_thr);

end
