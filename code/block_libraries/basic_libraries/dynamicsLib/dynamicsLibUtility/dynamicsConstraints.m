classdef dynamicsConstraints < handle
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% dynamicsConstraints: Class that defines that constraints on the dynamics
% of the aircraft

    properties (GetAccess = 'public', SetAccess = 'public')
        maxAirspeed_ftps                = 1116; 
        minAirspeed_ftps                = 1.7;
        maxAcceleration_ftpss           = 1e6;
        minAcceleration_ftpss           = -1e6;
        maxVerticalRate_ftps            = 1e4;
        minVerticalRate_ftps            = -1e4;
        maxPitchRate_radps              = 3*DEGAS.deg2rad;
        maxBankAngle_rad                = 75*DEGAS.deg2rad;    
        maxRollRate_radps               = 0.524;
        maxYawRate_radps                = 1e6;
        
        dynamicsNumeratorRollRate       = [1;0];
        dynamicsDenominatorRollRate     = 0;
        dynamicsNumeratorVerticalRate   = [1;0];
        dynamicsDenominatorVerticalRate = 0;
        dynamicsNumeratorYawRate        = [1;0];
        dynamicsDenominatorYawRate      = 0;        
    end
    
    % Properties in aviation units
    properties( Dependent = true )
        maxAirspeed_knots
    end    
%% Getters
% These methods return the reported error values. The method does not have
% to be called explicitly, i.e. running
% "simObj.ac1Dyn.dynCon.maxAirspeed_knots" in the command line
% would call get.maxAirspeed_knots(this)      

    methods
        function v = get.maxAirspeed_knots( this )   
            v = DEGAS.ftps2kt*this.maxAirspeed_ftps;
        end
    end
    properties( Dependent = true )
        minAirspeed_knots
    end
    methods
        function v = get.minAirspeed_knots( this )   
            v = DEGAS.ftps2kt*this.minAirspeed_ftps;
        end
    end
    properties( Dependent = true )
        maxVerticalRate_ftpmin
        minVerticalRate_ftpmin
    end
    methods
        function v = get.maxVerticalRate_ftpmin( this )
            v = (1/DEGAS.sec2min)*this.maxVerticalRate_ftps;
        end
        function v = get.minVerticalRate_ftpmin( this )
            v = (1/DEGAS.sec2min)*this.minVerticalRate_ftps;
        end
        function set.maxVerticalRate_ftpmin( this, value )
            this.maxVerticalRate_ftps = value/DEGAS.min2sec;
        end
        function set.minVerticalRate_ftpmin( this, value )
            this.minVerticalRate_ftps = value/DEGAS.min2sec;
        end
    end    

    properties(Dependent)
        maxPitchRate_degps
        maxBankAngle_deg
        maxRollRate_degps
        maxYawRate_degps
    end
    methods
        function v = get.maxPitchRate_degps( this )
            v = DEGAS.rad2deg*this.maxPitchRate_radps;
        end
        function v = get.maxBankAngle_deg( this )
            v = DEGAS.rad2deg*this.maxBankAngle_rad;
        end
        function set.maxBankAngle_deg( this, v )
            this.maxBankAngle_rad = DEGAS.rad2deg*v;
        end
        function v = get.maxRollRate_degps( this )
            v = DEGAS.rad2deg*this.maxRollRate_radps;
        end
        function v = get.maxYawRate_degps( this )
            v = DEGAS.rad2deg*this.maxYawRate_radps;
        end        
    end    
    methods
        function obj = dynamicsConstraints(varargin)
            p = inputParser; 
            
            addOptional(p,'maxAirspeed_ftps',obj.maxAirspeed_ftps,@isnumeric);
            addOptional(p,'minAirspeed_ftps',obj.minAirspeed_ftps,@isnumeric);
            addOptional(p,'maxAcceleration_ftpss',obj.maxAcceleration_ftpss,@isnumeric);
            addOptional(p,'minAcceleration_ftpss',obj.minAcceleration_ftpss,@isnumeric);
            addOptional(p,'maxVerticalRate_ftps',obj.maxVerticalRate_ftps,@isnumeric);
            addOptional(p,'minVerticalRate_ftps',obj.minVerticalRate_ftps,@isnumeric);
            addOptional(p,'maxPitchRate_radps',obj.maxPitchRate_radps,@isnumeric);
            addOptional(p,'maxBankAngle_rad',obj.maxBankAngle_rad,@isnumeric);
            addOptional(p,'maxRollRate_radps',obj.maxRollRate_radps,@isnumeric);
            addOptional(p,'maxYawRate_radps',obj.maxYawRate_radps,@isnumeric);
            addOptional(p,'dynamicsNumeratorRollRate',obj.dynamicsNumeratorRollRate,@isnumeric);
            addOptional(p,'dynamicsDenominatorRollRate',obj.dynamicsDenominatorRollRate,@isnumeric);
            addOptional(p,'dynamicsNumeratorVerticalRate',obj.dynamicsNumeratorVerticalRate,@isnumeric);
            addOptional(p,'dynamicsDenominatorVerticalRate',obj.dynamicsDenominatorVerticalRate,@isnumeric);
            addOptional(p,'dynamicsNumeratorYawRate',obj.dynamicsNumeratorYawRate,@isnumeric);
            addOptional(p,'dynamicsDenominatorYawRate',obj.dynamicsDenominatorYawRate,@isnumeric);            
            
            parse(p,varargin{:});          
        end 
%% Setters
% Setter functions set the value of the property of the object by calling
% the appropriate set function. The set functions have input handling built
% in so that the value the property is set to is valid. Like the
% aforementioned getter functions, the setter functions are not called
% explicitly, i.e. running 
% "simObj.ac1Dyn.dynCon.maxAirspeed_ftps = 1" in the command line will call
% set.maxAirspeed_ftps(obj, value)

        function set.maxAirspeed_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for maximum airspeed: maxAirspeed_ftps must be >=0');
            else
               obj.checkAirspeed('max',value);
               obj.maxAirspeed_ftps = value;
            end
         end
         function set.minAirspeed_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for minimum airspeed: minAirspeed_ftps must be >=0');
            else
                obj.checkAirspeed('min',value);
                obj.minAirspeed_ftps = value;
            end
         end
         function set.maxAcceleration_ftpss(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for maximum acceleration: maxAcceleration_ftpss must be >=0');
            else
                obj.checkAcceleration('max',value);
                obj.maxAcceleration_ftpss = value;
            end
         end
         function set.minAcceleration_ftpss(obj, value)
            if(~isnumeric(value))
                error('Invalid value for minimum acceleration: minAcceleration_ftpss must be numeric');
            else
                obj.checkAcceleration('min',value);
                obj.minAcceleration_ftpss = value;
            end
         end
         function set.maxVerticalRate_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for maximum vertical rate: maxVerticalRate_ftps must be >=0');
            else
                obj.checkVertRate('max',value);
                obj.maxVerticalRate_ftps = value;
            end
         end
         function set.minVerticalRate_ftps(obj, value)
            if(~isnumeric(value))
                error('Invalid value for minimum vertical rate: minVerticalRate_ftps must be numeric');
            else
                obj.checkVertRate('min',value);
                obj.minVerticalRate_ftps = value;
            end
         end
         function set.maxPitchRate_radps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for maximum pitch rate: maxPitchRate_radps must be >=0');
            else
                obj.maxPitchRate_radps = value;
            end
         end
         function set.maxBankAngle_rad(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for maximum bank angle: maxBankAngle_rad must be >=0');
            else
                obj.maxBankAngle_rad = value;
            end
         end
         function set.maxRollRate_radps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for maximum roll rate: maxRollRate_radps must be >=0');
            else
                obj.maxRollRate_radps = value;
            end
         end
         function set.maxYawRate_radps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for maximum yaw rate: maxYawRate_radps must be >=0');
            else
                obj.maxYawRate_radps = value;
            end
         end
         function set.dynamicsNumeratorRollRate(obj, value)
            if ~all(size(value)==[2,1])
                error('Invalid value for dynamics numerator roll rate: dynamicsNumeratorRollRate must be a 2-element column vector');
            elseif(~isnumeric(value) || any(value < 0))
                error('Invalid value for dynamics numerator roll rate: dynamicsNumeratorRollRate must be >=0');
            else
                obj.dynamicsNumeratorRollRate = value;
            end
         end
         function set.dynamicsDenominatorRollRate(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for dynamics denominator roll rate: dynamicsDenominatorRollRate must be >=0');
            else
                obj.dynamicsDenominatorRollRate = value;
            end
         end
         function set.dynamicsNumeratorVerticalRate(obj, value)
            if ~all(size(value)==[2,1])
                error('Invalid value for dynamics numerator vertical rate: dynamicsNumeratorRollRate must be a 2-element column vector');
            elseif(~isnumeric(value) || any(value < 0))
                error('Invalid value for dynamics numerator vertical rate: dynamicsNumeratorRollRate must be >=0');
            else
                obj.dynamicsNumeratorVerticalRate = value;
            end
         end
         function set.dynamicsDenominatorVerticalRate(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for dynamics denominator vertical rate: dynamicsDenominatorVerticalRate must be >=0');
            else
                obj.dynamicsDenominatorVerticalRate = value;
            end
         end
         function set.dynamicsNumeratorYawRate(obj, value)
            if ~all(size(value)==[2,1])
                error('Invalid value for dynamics numerator yaw rate: dynamicsNumeratorYawRate must be a 2-element column vector');
            elseif(~isnumeric(value) || any(value < 0))
                error('Invalid value for dynamics numerator yaw rate: dynamicsNumeratorYawRate must be >=0');
            else
                obj.dynamicsNumeratorYawRate = value;
            end
         end
         function set.dynamicsDenominatorYawRate(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for dynamices denominator yaw rate: dynamicsDenominatorYawRate must be >=0');
            else
                obj.dynamicsDenominatorYawRate = value;
            end
         end 
        function checkAirspeed(obj,minMax,value)
            if strcmp(minMax,'min')
                if(obj.maxAirspeed_ftps < value)
                    error('minAirspeed_ftps must be < maxAirspeed_ftps');
                end
            elseif strcmp(minMax,'max')
                if(value < obj.minAirspeed_ftps)
                    error('maxAirspeed_ftps must be > minAirspeed_ftps');
                end
            end
        end
        function checkAcceleration(obj,minMax,value)
            if strcmp(minMax,'min')
                if(obj.maxAcceleration_ftpss < value)
                    error('minAcceleration_ftpss must be < maxAcceleration_ftpss');
                end
            elseif strcmp(minMax,'max')
                if(value < obj.minAcceleration_ftpss)
                    error('maxAcceleration_ftpss must be > minAcceleration_ftpss');
                end
            end
        end
        function checkVertRate(obj,minMax,value)
            if strcmp(minMax,'min')
                if(obj.maxVerticalRate_ftps < value)
                    error('minVerticalRate_ftps must be < maxVerticalRate_ftps');
                end
            elseif strcmp(minMax,'max')
                if(value < obj.minVerticalRate_ftps)
                    error('maxVerticalRate_ftps must be > minVerticalRate_ftps');
                end
            end
        end         
    end    
end