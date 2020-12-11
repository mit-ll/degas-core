 classdef (Sealed = true) PerfectSurveillance < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% PerfectSurveillance: Simulates a sensor with no noise

    properties
        surveillanceSampletime_s = 0.1; % Sensor sample time, in seconds
    end
    methods
        function obj = PerfectSurveillance (tunableParameterPrefix,varargin)
            if( nargin < 1 )
                    tunableParameterPrefix = '';
            end
                
            p = inputParser;
            % Required parameters
            addRequired(p,'tunableParameterPrefix',@ischar);
            addParameter(p,'surveillanceSampletime_s',obj.surveillanceSampletime_s,@isnumeric);
            
            parse(p,tunableParameterPrefix,varargin{:});
            
            obj.tunableParameterPrefix = p.Results.tunableParameterPrefix;      
        end % End constructor
        function set.surveillanceSampletime_s(obj,value)
            if(~isnumeric(value) || value <= 0)
                error('Invalid surveillance sample time. surveillanceSampletime_s must be a number greater than zero.');
            end
            obj.surveillanceSampletime_s = value;
        end
    end % End methods
end % End classef