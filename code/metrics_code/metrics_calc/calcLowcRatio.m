function [ lowc_ratio, lowc_ratio_ci] = calcLowcRatio(lowcs, nomLowcs, varargin)
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% calcLowcRatio: Calculates and checks the Loss of Well Clear (LoWC) ratio. 
% Outputs warnings and errors if there are suspicious findings, 
% i.e. LoWC Ratio > 1, no nominal LoWC, etc.
%
% lowcs 1xN vector of logical LoWC values
% nomLowcs 1xN vector of logical LoWC values for the nominal case
% weights 1xN vector of encounter weights, default value is vector of ones
% CICheckThresh Threshold for how big the confidence interval half distance
% can be, in relation to the risk ratio. default value is 0.5.
% indices 1xN logical vector of which encounters to use for calculating 
% the LoWC ratio, default is using all encounters

    p = inputParser;
    addRequired(p,'lowcs',@islogical);
    addRequired(p,'nomLowcs',@islogical);
    addParameter(p,'weights',ones(1,length(lowcs)),@mustBePositive);
    addParameter(p,'CICheckThresh',0.5,@mustBePositive);
    addParameter(p,'indices',true(1,length(lowcs)),@islogical);
    parse(p,lowcs,nomLowcs,varargin{:});

    lowcs = p.Results.lowcs;
    nomLowcs = p.Results.nomLowcs;
    weights = p.Results.weights;
    CICheckThresh = p.Results.CICheckThresh;
    indices = p.Results.indices;

    % Input error checking
    assert(isvector(lowcs) && isvector(nomLowcs),...
        'lowc, nomLowcs must be logical vectors.');
    assert(isvector(weights),...
        'weights is not a vector. weights must be a vector of the same length as lowc and nomLowcs.');        
    assert((length(lowcs) == length(nomLowcs)) && (length(lowcs) == length(weights)) && (length(lowcs) == length(indices)),...
        'Inputs must be of equal length.');       
    if (sum(lowcs) == 0)
        warning('There are no lowc in the lowc vector.');
    end    
    if sum(nomLowcs) == 0
        error('There are no lowc in the nomLowcs vector.');
    end    
    if any(weights <= 0)
        error('weights must be greater than 0.');
    end
    if all(indices == false)
        error('indices must have at least 1 true element');
    end

    % Calculate lowc ratio
    [ lowc_ratio, lowc_ratio_induced, lowc_ratio_stddev_analytic,...
      lowc_ratio_ci, lowc_ratio_stddev_bootstrap ] = ...
      computeMetric( lowcs(indices), nomLowcs(indices), weights(indices) );    

    % Post-processing warnings
    if (lowc_ratio >= 1)
       warning('Calculated LoWC Ratio is greater than or equal to 1.'); 
    end
    
    checkLowcRatio(lowc_ratio, lowc_ratio_ci, 'CICheckThresh', CICheckThresh);
  
end