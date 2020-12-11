function delta_heading = compute_delta_heading(heading)
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% compute the acute change in heading (in degrees)

h = heading(1:(end-1));
hh = heading(2:end);
delta_heading = abs(h - hh);
i = delta_heading > 180;
delta_heading(i) = 360 - delta_heading(i);
i = mod(h + delta_heading, 360) ~= hh;
delta_heading(i) = -delta_heading(i);
