function [ ratio, ratio_induced, stddev_analytic, ratio_ci, stddev_bootstrap ] = computeMetric( metric, metricNom, w )
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% computeMetric: Computes ratio metrics and confidence intervals
% 
% INPUTS:
% metric    - 1xN vector of collected statistic of interest
% metricNom - 1xN vector of nominal statistic of interest 
% w         - 1xN vector of encounter weights
%
% OUTPUTS:
% ratio         - Calculated metric ratio
% ratio_induced - Contribution to metric ratio by induced events (events
% that occurred in mitigated encounter but not a nominal encounter)
% stddev_analytic - Standard deviation of the metric ratio calculated 
% analytically
% ratio_ci - 95% confidence bounds of the metric ratio
% stddev_bootstrap - Standard deviation of the metric ratio calculated by
% the bootstrap method

% Weighted probability of metric
pmetric = sum(metric.*w)./sum(w);
% Weighted probability of nominal metric
pmetricNom = sum(metricNom.*w)/sum(w);

% Metric ratio
ratio = pmetric/pmetricNom;

% Find induced events
induced = metric-metricNom;
induced(induced<0) = 0;

% Probability of metric in induced cases
pmetricInduced = sum(induced.*w)./sum(w);

% Induced metric ratio
ratio_induced = pmetricInduced/pmetricNom;

if nargout>2   
    stddev_analytic = sqrt( sum((w.*(metric-pmetric)).^2)/sum(w)^2)/pmetricNom; % http://www.jstor.org/stable/1913710 - Theorem 2 - this appears more accurate
end

% Compute bootstrap if needed
if nargout>3
    [ratio_ci,bootstat] = bootci(100,{@(x,y)sum(x)/sum(y),metric.*w,metricNom.*w},'type','cper');
    stddev_bootstrap = std(bootstat);
end

end

