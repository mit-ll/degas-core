function [ risk_ratio, risk_ratio_ci ] = calcRiskRatio(nmacs, nomNmacs, varargin)
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% calcRiskRatio: Calculates and checks the risk ratio. Outputs warnings and
% errors if there are suspicious findings, i.e. Risk Ratio > 1, no nominal 
% nmacs, etc.
%
% nmacs 1xN vector of logical nmac values
% nomNmacs 1xN vector of logical nmac values for the nominal case
% weights 1xN vector of encounter weights, default value is vector of ones
% CICheckThresh Threshold for how big the confidence interval half distance
% can be, in relation to the risk ratio. default value is 0.5.
% indices 1xN logical vector of which encounters to use for calculating 
% the risk ratio, default is using all encounters

    p = inputParser;
    addRequired(p,'nmacs',@islogical);
    addRequired(p,'nomNmacs',@islogical);
    addParameter(p,'weights',ones(1,length(nmacs)),@mustBePositive);
    addParameter(p,'CICheckThresh',0.5,@mustBePositive);
    addParameter(p,'indices',true(1,length(nmacs)),@islogical);
    parse(p,nmacs,nomNmacs,varargin{:});

    nmacs = p.Results.nmacs;
    nomNmacs = p.Results.nomNmacs;
    weights = p.Results.weights;
    CICheckThresh = p.Results.CICheckThresh;
    indices = p.Results.indices;

    % Input error checking
    assert(isvector(nmacs) && isvector(nomNmacs),...
        'nmac, nomNmacs must be logical vectors.');
    assert(isvector(weights),...
        'weights is not a vector. weights must be a vector of the same length as nmacs and nomNmacs.');        
    assert((length(nmacs) == length(nomNmacs)) && (length(nmacs) == length(weights)) && (length(nmacs) == length(indices)),...
        'Inputs must be of equal length.');       
    if (sum(nmacs) == 0)
        warning('There are no nmacs in the nmacs vector.');
    end    
    if sum(nomNmacs) == 0
        error('There are no nmacs in the nomNmacs vector.');
    end    
    if any(weights <= 0)
        error('weights must be greater than 0.');
    end    
    if all(indices == false)
        error('indices must have at least 1 true element');
    end    

    % Calculate risk ratio
    [ risk_ratio, risk_ratio_induced, risk_ratio_stddev_analytic,...
      risk_ratio_ci, risk_ratio_stddev_bootstrap ] = ...
      computeMetric( nmacs(indices), nomNmacs(indices), weights(indices) );    

    % Post-processing warnings
    if (risk_ratio >= 1)
       warning('Calculated Risk Ratio is greater than or equal to 1.'); 
    end
    
    checkRiskRatio(risk_ratio, risk_ratio_ci, 'CICheckThresh', CICheckThresh);
  
end