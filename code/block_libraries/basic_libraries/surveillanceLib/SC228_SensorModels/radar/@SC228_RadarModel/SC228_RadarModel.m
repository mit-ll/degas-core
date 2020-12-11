classdef (Sealed = false) SC228_RadarModel < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% SC228_RadarModel: This Simulink block models an Radar sensor according to
% RTCA SC-228 MOPS (DO-365 Appendix Q)
    
    %%
    properties (GetAccess = 'public', SetAccess = 'public')               
     % Values from DAA MOPS DO-365 Appendix Q
     
     dt_s = 0.1; % Sensor simulation rate (s)
        
     % These values determine the properties of the signals output by the
     % sensor
     % Suffix meanings:
     % _random_stddev_*: Standard deviation of the error
     % _tau_s: Time correlation of the signal in seconds
     % _bias_stddev_*: Bias of the error     
     
     % Range properties
     rng_random_stddev_ft = 21.34*DEGAS.m2ft;
     rng_tau_s = 0;
     rng_bias_stddev_ft = 15.24*DEGAS.m2ft;
     
     % Range-rate properties
     rngdot_random_stddev_ftps = 3.0*DEGAS.m2ft;
     rngdot_tau_s = 0;
     rngdot_bias_stddev_ftps = 2.4*DEGAS.m2ft;
     
     % Azimuth properties
     az_random_stddev_rad = 1.0*DEGAS.deg2rad;
     az_tau_s = 0;
     az_bias_stddev_rad = 0.5*DEGAS.deg2rad;
     
     % Elevation properties
     el_random_stddev_rad = 1.0*DEGAS.deg2rad;
     el_tau_s = 0;
     el_bias_stddev_rad = 0.5*DEGAS.deg2rad;

     % Maximum Field of Regard for azimuth and elevation
     sns_for_azimuth_deg = 110;
     sns_for_elevation_deg = 15;
     
     % The bias values for the Range, Range-rate, Azimuth, and Elevation
     % signals. These are set by the prepareProperties function of
     % this class.     
     
     % Constant Biases
     rng_bias_ft
     rngdot_bias_ftps
     az_bias_rad
     el_bias_rad
     
     % The seeds are used for noise generation. Normally, the user will
     % never have to set these values. They are set in the 
     % prepareProperties function of this class.      
     
     seed1
     seed2
     seed3
     seed4
     
     % This properties control Radar behavior
     isEnabled = true; % If true, the Radar sensor is enabled.
     debugMode = false; % Whether to run in debug mode with infinite detection range
     RCPR_Mode = true; % Whether to enable a minimum detection range
     RCPR_Range_ft = 4000; % Currently, the minimum detection range is 4000 ft
    end % end properties
    
    properties(Dependent)
     % Reported error covariance
     reported_range_error_var_ft2
     reported_azimuth_error_var_rad2
     reported_elevation_error_var_rad2
     reported_range_rate_error_var_fps2
    end    
%% Getters
% These methods return the reported error values. The method does not have
% to be called explicitly, i.e. running
% "simObj.ac1RdrSens.reported_range_error_var_ft2" in the command line
% would call get.reported_range_error_var_ft2(this) 

    methods
        function val = get.reported_range_error_var_ft2(this)
            val = this.rng_random_stddev_ft^2 + this.rng_bias_stddev_ft^2;            
        end
        function val = get.reported_azimuth_error_var_rad2(this)
            val = this.az_random_stddev_rad^2 + this.az_bias_stddev_rad^2;            
        end
        function val = get.reported_elevation_error_var_rad2(this)
            val = this.el_random_stddev_rad^2 + this.el_bias_stddev_rad^2;            
        end
        function val = get.reported_range_rate_error_var_fps2(this)
            val = this.rngdot_random_stddev_ftps^2 + this.rngdot_bias_stddev_ftps^2;
        end
    end
    properties(Dependent)
        reported_errorCovRAE % Range (ft), Az (rad), El (rad), Range rate (fps)
    end
    methods
        function val = get.reported_errorCovRAE(this)
            val = diag( [ this.reported_range_error_var_ft2 this.reported_azimuth_error_var_rad2 this.reported_elevation_error_var_rad2...
                this.reported_range_rate_error_var_fps2 ] );
        end
    end
    
    %% Constructor
    methods
        function obj = SC228_RadarModel (tunableParameterPrefix,varargin)
            if( nargin < 1 )
                tunableParameterPrefix = '';
            end
            
            p = inputParser;
            % Required parameters
            addRequired(p,'tunableParameterPrefix',@ischar);
            
            addOptional(p, 'dt_s', obj.dt_s, @isnumeric);
            addOptional(p, 'rng_random_stddev_ft', obj.rng_random_stddev_ft, @isnumeric);
            addOptional(p, 'rng_tau_s', obj.rng_tau_s, @isnumeric);
            addOptional(p, 'rng_bias_stddev_ft', obj.rng_bias_stddev_ft, @isnumeric);
            addOptional(p, 'rngdot_random_stddev_ftps', obj.rngdot_random_stddev_ftps, @isnumeric);
            addOptional(p, 'rngdot_tau_s', obj.rngdot_tau_s, @isnumeric);
            addOptional(p, 'rngdot_bias_stddev_ftps', obj.rngdot_bias_stddev_ftps, @isnumeric);
            addOptional(p, 'az_random_stddev_rad', obj.az_random_stddev_rad, @isnumeric);
            addOptional(p, 'az_tau_s', obj.az_tau_s, @isnumeric);
            addOptional(p, 'az_bias_stddev_rad', obj.az_bias_stddev_rad, @isnumeric);
            addOptional(p, 'el_random_stddev_rad', obj.el_random_stddev_rad, @isnumeric);
            addOptional(p, 'el_tau_s', obj.el_tau_s, @isnumeric);
            addOptional(p, 'el_bias_stddev_rad', obj.el_bias_stddev_rad, @isnumeric);
            addOptional(p, 'sns_for_azimuth_deg', obj.sns_for_azimuth_deg, @isnumeric);
            addOptional(p, 'sns_for_elevation_deg', obj.sns_for_elevation_deg, @isnumeric);
            addOptional(p, 'isEnabled', obj.isEnabled, @islogical);
            addOptional(p, 'debugMode', obj.debugMode, @islogical);
            addOptional(p, 'RCPR_Mode', obj.RCPR_Mode, @islogical);
            addOptional(p, 'RCPR_Range_ft', obj.RCPR_Range_ft, @isnumeric);
            
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
% explicitly, i.e. running "simObj.ac1RdrSens.dt_s = 1" in the command
% line will call set.dt_s(obj, value)

        function set.dt_s(obj, value)
            if(value <= 0)
                error('Invalid value for time step. dt_s must be a number greater than zero.');
            else
                obj.dt_s = value;
            end
        end
        function set.rng_random_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for range standard deviation. rng_random_stddev_ft must be a number greater than zero.');
            else
                obj.rng_random_stddev_ft = value;
            end
        end
        function set.rng_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for range time correlation. rng_tau_s must be a number greater than zero.');
            else
                obj.rng_tau_s = value;
            end
        end
        function set.rng_bias_stddev_ft(obj, value)
            if(~isnumeric(value))
                error('Invalid value for range bias. rng_bias_stddev_ft must be a number.');
            else
                obj.rng_bias_stddev_ft = value;
            end
        end
        function set.rngdot_random_stddev_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for range rate standard deviation. rngdot_random_stddev_ftps must be a number greater than zero.');
            else
                obj.rngdot_random_stddev_ftps = value;
            end
        end
        function set.rngdot_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for range rate time correlation. rngdot_tau_s must be a number greater than zero.');
            else
                obj.rngdot_tau_s = value;
            end
        end
        function set.rngdot_bias_stddev_ftps(obj, value)
            if(~isnumeric(value))
                error('Invalid value for range rate bias. rngdot_bias_stddev_ftps must be a number.');
            else
                obj.rngdot_bias_stddev_ftps = value;
            end
        end
        function set.az_random_stddev_rad(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for azimuth standard deviation. az_random_stddev_rad must be a number greater than zero.');
            else
                obj.az_random_stddev_rad = value;
            end
        end
        function set.az_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for azimuth time correlation. az_tau_s must be a number greater than zero.');
            else
                obj.az_tau_s = value;
            end
        end
        function set.az_bias_stddev_rad(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for azimuth bias. az_bias_stddev_rad must be a number.');
            else
                obj.az_bias_stddev_rad = value;
            end
        end
        function set.el_random_stddev_rad(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for elevation standard deviation. el_random_stddev_rad must be a number greater than zero.');
            else
                obj.el_random_stddev_rad = value;
            end
        end
        function set.el_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for elevation time correlation. el_tau_s must be a number greater than zero.');
            else
                obj.el_tau_s = value;
            end
        end
        function set.el_bias_stddev_rad(obj, value)
            if(~isnumeric(value))
                error('Invalid value for elevation bias. el_bias_stddev_rad must be a number.');
            else
                obj.el_bias_stddev_rad = value;
            end
        end
        function set.sns_for_azimuth_deg(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for FOR azimuth. sns_for_azimuth_deg must be a number greater than or equal to zero.');
            else
                obj.sns_for_azimuth_deg = value;
            end
        end
        function set.sns_for_elevation_deg(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for FOR elevation. sns_for_elevation_deg must be a number greater than or equal to zero.');
            else
                obj.sns_for_elevation_deg = value;
            end
        end
        function set.isEnabled(obj, value)
            if(~islogical(value))
                error('Invalid value for enabled. isEnabled must be true or false.');
            else
                obj.isEnabled = value;
            end
        end
        function set.debugMode(obj, value)
            if(~islogical(value))
                error('Invalid value for debug mode. debugMode must be true or false.');
            else
                obj.debugMode = value;
            end
        end
        function set.RCPR_Mode(obj, value)
            if(~islogical(value))
                error('Invalid value for RCPR Mode. RCPR_Mode must be true or false.');
            else
                obj.RCPR_Mode = value;
            end
        end
        function set.RCPR_Range_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for RCPR Range. must be a number greater than or equal to zero.');
            else
                obj.RCPR_Range_ft = value;
            end
        end
    end % End methods
    
    %%
    methods(Access = 'public')
        function prepareProperties(obj)
            
            % set biases
            
            obj.rng_bias_ft = obj.rng_bias_stddev_ft*(2*rand(1) - 1);
            obj.rngdot_bias_ftps = obj.rngdot_bias_stddev_ftps*(2*rand(1) - 1);
            obj.az_bias_rad = obj.az_bias_stddev_rad*(2*rand(1) - 1);
            obj.el_bias_rad = obj.el_bias_stddev_rad*(2*rand(1) - 1);

            % draw seeds for random error processes
            
            seeds = randi(4294967295,6); % 4294967295 = 2^32 - 1
            obj.seed1 = seeds(1);
            obj.seed2 = seeds(2);
            obj.seed3 = seeds(3);
            obj.seed4 = seeds(4);
                                    
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
                    'reported_azimuth_error_var_rad2', ...
                    'reported_elevation_error_var_rad2', ...
                    'reported_range_rate_error_var_fps2', ...
                    'reported_azimuth_rate_error_var_rps2', ...
                    'reported_elevation_rate_error_var_rps2' ...
                    'rng_bias_stddev_ft', ...
                    'rngdot_bias_stddev_ftps', ...
                    'az_bias_stddev_rad', ...
                    'el_bias_stddev_rad', ...
                            });
            end                        
            
            [varName, varValue] = this.getTunableParameters@Block( varName );
        end
    end
        
end % End classef