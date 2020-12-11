classdef (Sealed = false) SC228_TrackedActiveSurveillanceModel < SC228_ActiveSurveillanceModel
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% SC228_TrackedActiveSurveillanceModel: This Simulink block models an 
% Active Surveillance sensor being used with a tracker. Tracker errors are 
% modeled after DO-365 Table 2-20.
    
    %%
    properties (GetAccess = 'public', SetAccess = 'public')               
     % Values from DAA MOPS DO-365 Table 2-20
     % "Single-Source Integrated Track Performance"
     
     % The standard deviation and bias of the bearing and bearing rate 
     % errors based on the RTCA SC-228 DAA MOPS DO-365 Table 2-20          
     psi_stddev_ft = 1000*(10000 - 0.5*DEGAS.nm2ft) + 1250;
     psi_bias_ft = 0;
     
     psidot_stddev_ftps = 33*(10000 - 0.5*DEGAS.nm2ft) + 85*DEGAS.kt2ftps;
     psidot_bias_ftps = 0;
    end % end properties
    
    %% Constructor
    methods
        function obj = SC228_TrackedActiveSurveillanceModel (tunableParameterPrefix,varargin)
            if( nargin < 1 )
                tunableParameterPrefix = '';
            end
            
            p = inputParser;
            % Required parameters
            addRequired(p,'tunableParameterPrefix',@ischar);
            addParameter(p, 'dt_s', obj.dt_s, @isnumeric);
            addOptional(p, 'psi_stddev_ft', obj.psi_stddev_ft, @isnumeric);
            addOptional(p, 'psi_bias_ft', obj.psi_stddev_ft, @isnumeric);
            addOptional(p, 'psidot_stddev_ftps', obj.psidot_stddev_ftps, @isnumeric);
            addOptional(p, 'psidot_bias_ftps', obj.psidot_stddev_ftps, @isnumeric);
            
            parse(p,tunableParameterPrefix,varargin{:});
            
            fieldsSet = intersect( fieldnames(p.Results), fieldnames(obj) );
            for i = 1:1:numel(fieldsSet)
                obj.(fieldsSet{i}) = p.Results.(fieldsSet{i});
            end
        end % End constructor     
%% Setters
% Setter functions set the value of the property of the object by calling
% the appropriate set function. The set functions have input handling built
% in so that the value the property is set to is valid. Like the
% aforementioned getter functions, the setter functions are not called
% explicitly, i.e. running "simObj.ac1TrkdAstSens.psi_stddev_ft = 1" in the 
% command line will call set.psi_stddev_ft(obj, value) 

        function set.psi_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for tracked heading standard deviation. psi_stddev_ft must be a number greater than or equal to zero.');
            else
                obj.psi_stddev_ft = value;
            end
        end
        function set.psi_bias_ft(obj, value)
            if(~isnumeric(value))
                error('Invalid value for tracked heading bias. psi_bias_ft must be a number.');
            else
                obj.psi_bias_ft = value;
            end
        end
        function set.psidot_stddev_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for tracked heading rate standard deviation. psidot_stddev_ftps must be a number greater than zero.');
            else
                obj.psidot_stddev_ftps = value;
            end
        end
        function set.psidot_bias_ftps(obj, value)
            if(~isnumeric(value))
                error('Invalid value for tracked heading rate bias. psidot_bias_ftps must be a number.');
            else
                obj.psidot_bias_ftps = value;
            end
        end
    end % End methods
    %%
    methods(Access = 'public')
        function prepareProperties(obj)
            % set biases
            obj.psi_bias_rad = obj.psi_bias_stddev_rad*(2*rand(1) - 1);
            obj.psidot_bias_radps = obj.psidot_bias_stddev_radps*(2*rand(1) - 1);                   

            % draw seeds for random error processes
            
            seeds = randi(4294967295,7); % 4294967295 = 2^32 - 1
            obj.seed1 = seeds(1);
            obj.seed2 = seeds(2);
            obj.seed3 = seeds(3);
            obj.seed4 = seeds(4);
            obj.seed5 = seeds(5);
            obj.seed6 = seeds(6);
            obj.randProbSeed = seeds(7);
            
            if(obj.intruder_mode == 0) %Mode S
                %Set appropriate surveillance parameters
                obj.rng_bias_ft = 125;
                obj.altQuant_ft = 25;
                obj.sns_max_front_range_ft = 15.6*DEGAS.nm2ft;
                obj.sns_max_side_range_ft = 15.6*DEGAS.nm2ft;
                obj.sns_max_rear_range_ft = 15.6*DEGAS.nm2ft;
                obj.probDetect = 1-(0.05)^(1/10); %prob single hit over 10 dsec
            elseif(obj.intruder_mode == 1) %Mode C
                obj.rng_bias_ft = 250;
                obj.altQuant_ft = 100;
                obj.sns_max_front_range_ft = 20.6*DEGAS.nm2ft;
                obj.sns_max_side_range_ft = 14.3*DEGAS.nm2ft;
                obj.sns_max_rear_range_ft = 8.0*DEGAS.nm2ft;
                obj.probDetect = 1-(0.10)^(1/10); %prob single hit over 10 dsec
            else %Test Mode
                
            end
                                    
        end
    end
    
    %% Overrides
    methods(Access=protected)        
        function [varName, varValue] = getTunableParameters( this, varName )
            %Return a list of the model parameters determined by this object and their values
            %
            % [varName, varValue] = block.getTunableParameters()
            %
            % varName - A cell array of strings containing the names of
            %     model parameters determined by this object
            %
            % varValue - A cell array of the corresponding values of the
            %     model parameters determined by this object
            %
            % Note that accepting varName parameter allows overriding
            % methods to call this base method with a list of variables
            % that omits properties of the object that should not be
            % treated as Simulink model parameters
            
            if( nargin < 2 )
                varName = setdiff( properties(this), { 'tunableParameterPrefix', 'type', ...
                    'reported_range_error_var_ft2', ...
                    'reported_bearing_error_var_rad2', ...
                    'reported_altitude_error_var_ft2', ...
                    'reported_range_rate_error_var_ftps2', ...
                    'reported_bearing_rate_error_var_rps2', ...
                    'reported_vertical_rate_error_var_ftps2' ...
                    'rng_bias_stddev_ft', ...
                    'rngdot_bias_stddev_ftps', ...
                    'psi_bias_stddev_rad', ...
                    'psidot_bias_stddev_radps', ...
                    'alt_bias_stddev_ft', ...
                    'altdot_bias_stddev_ftps' ...
                            });
            end                        
            [varName, varValue] = this.getTunableParameters@Block( varName );
        end
    end
end % End classef