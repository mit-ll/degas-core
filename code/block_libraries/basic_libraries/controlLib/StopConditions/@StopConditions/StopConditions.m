classdef (Sealed = true) StopConditions < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% StopConditions: Wrapper class used to set the parameters of DEGAS 
% "Stop Conditions" block located in StopConditions.slx
%
% The "Stop Conditions" block stops the simulation once a certain range or
% altitude difference between two aircraft has been reached.
   
    properties 
        stop_range_ft = 10*DEGAS.nm2ft;   % Stopping horizontal range in feet
        stop_altitude_ft = 10000;  % Stopping vertical separation in feet
    end
    
    methods
        function obj = StopConditions (tunableParameterPrefix,varargin)
            if( nargin < 1 )
                tunableParameterPrefix = '';
            end
            
            p = inputParser;
            % Required Parameters
            addRequired(p,'tunableParameterPrefix',@ischar);

            % Optional Parameters
            addParameter(p,'stop_range_ft',obj.stop_range_ft,@isnumeric);
            addParameter(p,'stop_altitude_ft',obj.stop_altitude_ft,@isnumeric);
            
            parse(p,tunableParameterPrefix,varargin{:}); 
            fieldsSet = intersect( fieldnames(p.Results), fieldnames(obj) );
            for i = 1:1:numel(fieldsSet)
                obj.(fieldsSet{i}) = p.Results.(fieldsSet{i});
            end
        end %End constructor
%% Setters
% Setter functions set the value of the property of the object by calling
% the appropriate set function. The set functions have input handling built
% in so that the value the property is set to is valid. Like the
% aforementioned getter functions, the setter functions are not called
% explicitly, i.e. running "simObj.ac1StopCond.stop_range_ft = 1" in the 
% command line will call set.stop_range_ft(obj, value)

        function set.stop_range_ft(obj,value)
            if(~isnumeric(value) || value < 0)
                error('Invalid horizontal stopping range. stop_range_ft should be a number greater than or equal to zero.');
            end
            obj.stop_range_ft = value;
        end
        function set.stop_altitude_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid vertical stopping separation. stop_altitude_ft should be a number greater than or equal to zero.');
            end
            obj.stop_altitude_ft = value;
        end
    end
end