function warnFlag = checkRiskRatio(risk_ratio, risk_ratio_ci, varargin)
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% checkRiskRatio: Checks to see if the risk ratio and confidence intervals
% are reasonable
% risk_ratio The calculated risk ratio
%
% risk_ratio_ci 2x1 vector of risk ratio confidence bounds. First element
% is the lower bound and second element is the higher bound
%
% CICheckThresh Threshold for how big the confidence interval half distance
% can be, in relation to the risk ratio. Default value is 0.5.

    warnFlag = false;

    p = inputParser;
    val_fxn = @(x) isscalar(x) && all(x >= 0);
    addRequired(p,'risk_ratio',val_fxn);
    val_fxn = @(x) all([size(x)] == [2,1]) && all(x >= 0);
    addRequired(p,'risk_ratio_ci',val_fxn);    
    addParameter(p,'CICheckThresh',0.5,@mustBePositive);
    parse(p,risk_ratio,risk_ratio_ci,varargin{:});

    risk_ratio = p.Results.risk_ratio;
    risk_ratio_ci = p.Results.risk_ratio_ci;
    CICheckThresh = p.Results.CICheckThresh;

    CItoRR = [risk_ratio - risk_ratio_ci(1); risk_ratio_ci(2) - risk_ratio];
    
    if any(CItoRR > (risk_ratio*CICheckThresh))
       warnFlag = true; 
       warning(['Risk Ratio confidence intervals are larger than expected.', newline,...
                'Risk ratio: ' num2str(risk_ratio), newline ,... 
                'Confidence Interval upper bound: ', num2str(risk_ratio_ci(2)), newline,...
                'Confidence Interval lower bound: ', num2str(risk_ratio_ci(1)), newline,... 
                'Risk ratio to upper bound: ', num2str(CItoRR(2)), newline,...
                'Risk ratio to lower bound: ', num2str(CItoRR(1)), newline,...
                'Acceptable difference: ', num2str((risk_ratio*CICheckThresh))]);         
    end
    
end