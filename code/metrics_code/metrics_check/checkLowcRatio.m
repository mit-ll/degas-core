function warnFlag = checkLowcRatio(lowc_ratio, lowc_ratio_ci, varargin)
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% checkLowcRatio: Checks to see if the Loss of Well Clear (LoWC) ratio and 
% confidence intervals are reasonable
% lowc_ratio The calculated LoWC ratio
%
% lowc_ratio_ci 2x1 vector of LoWC ratio confidence bounds. First element
% is the lower bound and second element is the higher bound
%
% CICheckThresh Threshold for how big the confidence interval half distance
% can be, in relation to the lowc ratio. Default value is 0.5.

    warnFlag = false;

    p = inputParser;
    val_fxn = @(x) isscalar(x) && all(x >= 0);
    addRequired(p,'lowc_ratio',val_fxn);
    val_fxn = @(x) all([size(x)] == [2,1]) && all(x >= 0);
    addRequired(p,'lowc_ratio_ci',val_fxn);    
    addParameter(p,'CICheckThresh',0.5,@mustBePositive);
    parse(p,lowc_ratio,lowc_ratio_ci,varargin{:});

    lowc_ratio = p.Results.lowc_ratio;
    lowc_ratio_ci = p.Results.lowc_ratio_ci;
    CICheckThresh = p.Results.CICheckThresh;

    CItoLowc = [lowc_ratio - lowc_ratio_ci(1); lowc_ratio_ci(2) - lowc_ratio];
    
    if any(CItoLowc > (lowc_ratio*CICheckThresh))
       warnFlag = true; 
       warning(['LoWC Ratio confidence intervals are larger than expected.', newline,...
                'LoWC ratio: ' num2str(lowc_ratio), newline ,... 
                'Confidence Interval upper bound: ', num2str(lowc_ratio_ci(2)), newline,...
                'Confidence Interval lower bound: ', num2str(lowc_ratio_ci(1)), newline,...
                'LoWC ratio to upper bound: ', num2str(CItoLowc(2)), newline,...
                'LoWC ratio to lower bound: ', num2str(CItoLowc(1)), newline,...
                'Acceptable difference: ', num2str((lowc_ratio*CICheckThresh))]);                
    end    
    
end