classdef (Sealed = true) HysteresisFilter < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% HysteresisFilter: Class that simulates hysteresis of a signal
    properties
        signalHoldTime = 4;    % How long to hold on to an signal
    end
    
    methods
        function obj = HysteresisFilter(tunableParameterPrefix,varargin) % Constructor
            if( nargin < 1 )
              tunableParameterPrefix = '';
            end

            p = inputParser;
            addRequired(p,'tunableParameterPrefix',@ischar);
            addOptional(p, 'signalHoldTime', obj.signalHoldTime, @isnumeric); 

            parse(p,tunableParameterPrefix,varargin{:});

            fieldsSet = intersect( fieldnames(p.Results), fieldnames(obj) );
            for i = 1:1:numel(fieldsSet)
              obj.(fieldsSet{i}) = p.Results.(fieldsSet{i});
            end
        end % constructor method    
%% Setters
% Setter functions set the value of the property of the object by calling
% the appropriate set function. The set functions have input handling built
% in so that the value the property is set to is valid. Like the
% aforementioned getter functions, the setter functions are not called
% explicitly, i.e. running "simObj.ac1HystFilt.signalHoldTime = 1" in the
% command line will call set.signalHoldTime(obj, value)

        function set.signalHoldTime(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for signal hold time: signalHoldTime must be >= 0');
            else
                obj.signalHoldTime = value;
            end
        end
    end    
end