function result = makeErrCheckHist(errorData,mu,sigma,yscale,nbins)
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% Check to see if error distribution is normally distributed with the 
% appropriate moments: N(0,theorSTD)
pdata = normcdf(errorData,mu,sigma);
pass = kstest(errorData,[errorData,pdata], 0.1);

% Plot error histograms and test resuts
histfit(errorData,nbins); hold on;
if ~pass
    h = text(mu,yscale-.1*yscale,'Pass');
    set(h,'FontSize',16,'color','green')
    result = 1;
else
    l = text(mu,yscale-.1*yscale,'Fail');
    set(l,'FontSize',16,'color','red')
    result = 0;
end

end