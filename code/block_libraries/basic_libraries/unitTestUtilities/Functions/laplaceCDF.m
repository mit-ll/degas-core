function p = laplaceCDF(x,mu,b)
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%

p = zeros(1,numel(x));
for j = 1:numel(x)
    if x(j) < mu
        p(j) = .5*exp((x(j)-mu)/b);
    else
        p(j) = 1-.5*exp(-(x(j)-mu)/b);
    end
end