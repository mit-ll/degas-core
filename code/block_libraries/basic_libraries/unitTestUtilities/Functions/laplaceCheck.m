%This function can be used to check if a set of values is from a Laplace %distribution.
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%

function result = laplaceCheck(errorData,mu,b,yscale,nbins)

b = b/(1.96*sqrt(2));

f = @(x) (1/(2*b)) .* exp(-abs(x-mu)./b);
x=-400:400; y = feval(f,x); yplot = y.*100; %used to be 10000 (not sure how that was chosen)
% Determine if samples correspond to the appropriate Laplacian CDF
pdata = laplaceCDF(errorData,mu,b);
pass = kstest(errorData,[errorData,pdata']);
histogram(errorData,nbins); hold on; xlim([-25 25]);
plot(x,yplot,'r','LineWidth',2);
if ~pass
    h = text(round(max(abs(errorData)))-.1*round(max(abs(errorData))),yscale-.1*yscale,'Pass');
    set(h,'FontSize',16,'color','green');
    result = 1;
else
    l = text(round(max(abs(errorData)))-.1*round(max(abs(errorData))),yscale-.1*yscale,'Fail');
    set(l,'FontSize',16,'color','red');
    result = 0;
end

end