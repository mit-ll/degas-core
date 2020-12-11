classdef WellClearMetrics < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% WellClearMetricsClass: Contains the properties that define the well clear
% boundary
   
    properties
        modTau % Modified Tau threshold, normally 35 seconds
        HMD % Horizontal Miss Distance threshold, normally 4000 ft
        TOCA % Time to co-altitude, normally 0 seconds
        altThresh % Altitude threshold, normally 450 ft
        rangeThresh % Range threshold, normally 4000 ft
    end
    
    methods
        function obj = WellClearMetrics(tunableParameterPrefix,varargin)
            if( nargin < 1 )
                tunableParameterPrefix = '';
            end
            p = inputParser;
            addRequired(p,'tunableParameterPrefix',@ischar);
            addParameter(p,'modTau',35,@isnumeric);
            addParameter(p,'HMD',4000,@isnumeric);
            addParameter(p,'TOCA',0,@isnumeric);
            addParameter(p,'altThresh',450,@isnumeric);
            addParameter(p,'rangeThresh',4000,@isnumeric);         
            
            parse(p,tunableParameterPrefix,varargin{:});
            
            fieldsSet = intersect( fieldnames(p.Results), fieldnames(obj) );
            for i = 1:1:numel(fieldsSet)
                obj.(fieldsSet{i}) = p.Results.(fieldsSet{i});
            end            
        end % Constructor
        function setWellClearToNoncoop(this) %SC-228 defn for non-cooperative intruders
            this.modTau       = 0;
            this.HMD          = 2200;
            this.TOCA         = 0;
            this.altThresh     = 450;
            this.rangeThresh   = 2200;            
        end
%% Setters
% Setter functions set the value of the property of the object by calling
% the appropriate set function. The set functions have input handling built
% in so that the value the property is set to is valid. Like the
% aforementioned getter functions, the setter functions are not called
% explicitly, i.e. running "simObj.ac1Wcm.modTau = 1" in the
% command line will call set.modTau(obj, value)

        function set.modTau(obj,value)
            if value < 0
               error('Invalid Modified Tau threshold: modTau must be greater than or equal to 0') 
            end
            obj.modTau = value;
        end
        
        function set.HMD(obj,value)
            if value < 0
               error('Invalid Horizontal Miss Distance threshold: HMD must be greater than or equal to 0') 
            end
            obj.HMD = value;
        end
        
        function set.TOCA(obj,value)
            if value < 0
               error('Invalid time to co-altitude: TOCA must be greater than or equal to 0') 
            end
            obj.TOCA = value;
        end        
        function set.altThresh(obj,value)
            if value < 0
               error('Invalid altitude threshold: altThresh must be greater than or equal to 0') 
            end
            obj.altThresh = value;
        end                
        function set.rangeThresh(obj,value)
            if value < 0
               error('Invalid range threshold: rangeThresh must be greater than or equal to 0') 
            end
            obj.rangeThresh = value;
        end                
    end
end