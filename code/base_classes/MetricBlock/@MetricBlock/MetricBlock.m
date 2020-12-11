classdef MetricBlock < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% MetricBlock: The parent class for Simulink blocks that record metrics. 
% Deriving a class from MetricBlock guarantees the recorded metrics are 
% added to the `simObj.outcome` field.
%
% Deriving a class from MetricBlock adds the recorded metrics to the 
% 'simObj.outcome' field

    methods
        function this = MetricBlock( simObj )
            assert( isa( simObj, 'Simulation' ), 'The object passed to MetricBlock must be a Simulation Object' );
            simObj.registerMetricBlock( this );
        end
    end    
    methods(Abstract)
        metricStruct = addMetrics( this, metricStruct ); % Add the metrics of this block as new fields to the provided structure
    end    
end