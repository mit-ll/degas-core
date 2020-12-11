classdef EOIRParametricModel < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% EOIRParametricModel: This Simulink block models an EOIR sensor according 
% to RTCA SC-228 EOIR MOPS

    properties (GetAccess = 'public', SetAccess = 'public')
         % Values from RTCA SC-228 EOIR MOPS
                 
         dt_s = 0.1; % Sensor simulation rate (s)
         range_clrd_noise_flag = 1; % Enables colored noise on range
         
         % These values determine the properties of the signals output by the
         % sensor
         % Suffix meanings:
         % _random_stddev_: Standard deviation of the error
         % _tau_s: Time correlation of the signal in seconds
         % _bias_stddev_*: Bias of the error              
         
         % Azimuth properties
         az_random_stddev_rad = 1.0e-3;
         az_tau_s = 0; 
         az_bias_stddev_rad = 0;

         % Elevation properties
         el_random_stddev_rad = 1.0e-3;
         el_tau_s = 0; 
         el_bias_stddev_rad = 0;

         % Azimuth rate properties
         azdot_random_stddev_radps = 1.4e-3;
         azdot_tau_s = 0; 
         azdot_bias_stddev_radps = 0;

         % Elevation rate properties
         eldot_random_stddev_radps = 1.4e-3;
         eldot_tau_s = 0 ;
         eldot_bias_stddev_radps = 0;
         
         % Range properties
         rng_random_stddev_ft = 15.24*DEGAS.m2ft;
         rng_tau_s = 5;
         rng_bias_stddev_ft = 0;      
         % Turn the range bias on or off
         rng_bias_switch = 0; 
         % The range error standard deviation is dependent on the true
         % range - e.g., range standard deviation = rng_std_dev_gain*range
         rng_std_dev_gain = 0.03;

         % Range-rate properties    
         rngdot_random_stddev_ftps = 3.6576*DEGAS.m2ft;
         rngdot_tau_s = 2;
         rngdot_bias_stddev_ftps = 0;         
         % Used to increase the standard deviation gain, since standard
         % deviation of the error signal is dependent on the true
         % range-rate value  - e.g., 
         % rang-rate standard deviation = rngdot_std_dev_gain*rangeRate
         rngdot_std_dev_gain = 0.05;
         % Once the intruder is within the field of regard, rngdot_delay_s
         % describes the amount of time before the range-rate being output
         % is valid
         rngdot_delay_s = 5; 

         % Field of Regard (FOR) limits
         sns_max_range_ft = 2.5*DEGAS.nm2ft; % Max detection range
         sns_for_azimuth_deg = Inf; % FOR for azimuth
         sns_for_elevation_deg = Inf; % FOR for elevation

         % The bias values for the range, range-rate, azimuth, azimuth rate,
         % elevation, and elevation rate signals. These are set by the 
         % prepareProperties function of this class.     
         % Constant Biases                  
         rng_bias_ft
         rngdot_bias_ftps
         az_bias_rad
         el_bias_rad
         azdot_bias_radps
         eldot_bias_radps
         
         % The seeds are used for noise generation. Normally, the user will
         % never have to set these values. They are set in the 
         % prepareProperties function of this class.   
         seed1
         seed2
         seed3
         seed4
         seed5
         seed6                  
         
        end % end properties

        properties(Dependent)
         % Reported error covariance
         reported_range_error_var_ft2
         reported_azimuth_error_var_rad2
         reported_elevation_error_var_rad2
         reported_range_rate_error_var_fps2
         reported_azimuth_rate_error_var_rps2
         reported_elevation_rate_error_var_rps2        
        end
        
%% Getters
% These methods return the reported error values. The method does not have
% to be called explicitly, i.e. running
% "simObj.ac1EOIRSens.reported_range_error_var_ft2" in the command line
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
            function val = get.reported_azimuth_rate_error_var_rps2(this)
                val = this.azdot_random_stddev_radps^2 + this.azdot_bias_stddev_radps^2;            
            end
            function val = get.reported_elevation_rate_error_var_rps2(this)
                val = this.eldot_random_stddev_radps^2 + this.eldot_bias_stddev_radps^2;            
            end        
        end
        properties(Dependent)
            reported_errorCovRAE % Range (ft), Az (rad), El (rad), Range rate (fps), Az rate (rps), El rate (rps)
        end
        methods
            function val = get.reported_errorCovRAE(this)
                val = diag( [ this.reported_range_error_var_ft2 this.reported_azimuth_error_var_rad2 this.reported_elevation_error_var_rad2...
                    this.reported_range_rate_error_var_fps2 this.reported_azimuth_rate_error_var_rps2 this.reported_elevation_rate_error_var_rps2 ] );
            end
        end

        %% Constructor
        methods
            function obj = EOIRParametricModel (tunableParameterPrefix,varargin)
                if( nargin < 1 )
                    tunableParameterPrefix = '';
                end

                p = inputParser;
                % Required parameters
                addRequired(p,'tunableParameterPrefix',@ischar);

                addOptional(p, 'dt_s', obj.dt_s, @isnumeric);
                addOptional(p, 'range_clrd_noise_flag', obj.range_clrd_noise_flag, @isnumeric);
                addOptional(p, 'rng_random_stddev_ft', obj.rng_random_stddev_ft, @isnumeric);
                addOptional(p, 'rng_tau_s', obj.rng_tau_s, @isnumeric);
                addOptional(p, 'rng_bias_stddev_ft', obj.rng_bias_stddev_ft, @isnumeric);
                addOptional(p, 'rng_bias_switch', obj.rng_bias_switch, @isnumeric);
                addOptional(p, 'rng_std_dev_gain', obj.rng_std_dev_gain, @isnumeric);
                addOptional(p, 'rngdot_random_stddev_ftps', obj.rngdot_random_stddev_ftps, @isnumeric);
                addOptional(p, 'rngdot_tau_s', obj.rngdot_tau_s, @isnumeric);
                addOptional(p, 'rngdot_bias_stddev_ftps', obj.rngdot_bias_stddev_ftps, @isnumeric);
                addOptional(p, 'rngdot_std_dev_gain', obj.rngdot_std_dev_gain, @isnumeric);
                addOptional(p, 'rngdot_delay_s', obj.rngdot_delay_s, @isnumeric);
                addOptional(p, 'az_random_stddev_rad', obj.az_random_stddev_rad, @isnumeric);
                addOptional(p, 'az_tau_s', obj.az_tau_s, @isnumeric);
                addOptional(p, 'az_bias_stddev_rad', obj.az_bias_stddev_rad, @isnumeric);
                addOptional(p, 'el_random_stddev_rad', obj.el_random_stddev_rad, @isnumeric);
                addOptional(p, 'el_tau_s', obj.el_tau_s, @isnumeric);
                addOptional(p, 'el_bias_stddev_rad', obj.el_bias_stddev_rad, @isnumeric);
                addOptional(p, 'azdot_random_stddev_radps', obj.azdot_random_stddev_radps, @isnumeric);
                addOptional(p, 'azdot_tau_s', obj.azdot_tau_s, @isnumeric);
                addOptional(p, 'azdot_bias_stddev_radps', obj.azdot_bias_stddev_radps, @isnumeric);
                addOptional(p, 'eldot_random_stddev_radps', obj.eldot_random_stddev_radps, @isnumeric);
                addOptional(p, 'eldot_tau_s', obj.eldot_tau_s, @isnumeric);
                addOptional(p, 'eldot_bias_stddev_radps', obj.eldot_bias_stddev_radps, @isnumeric);
                addOptional(p, 'sns_max_range_ft', obj.sns_max_range_ft, @isnumeric);
                addOptional(p, 'sns_for_azimuth_deg', obj.sns_for_azimuth_deg, @isnumeric);
                addOptional(p, 'sns_for_elevation_deg', obj.sns_for_elevation_deg, @isnumeric);

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
% explicitly, i.e. running "simObj.ac1EOIRSens.dt_s = 1" in the command
% line will call set.dt_s(obj, value)

            function set.dt_s(obj, value)
                if(value <= 0)
                    error('Invalid value for time step: dt_s must be > 0');
                else
                    obj.dt_s = value;
                end
            end
            function set.range_clrd_noise_flag(obj, value)
                if ~(value ==1 || value ==0)
                    error('Invalid value for range colored noise flag: range_clrd_noise_flag must be 0 or 1');
                else
                    obj.range_clrd_noise_flag = value;
                end
             end
            function set.rng_random_stddev_ft(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for range standard deviation: rng_random_stddev_ft must be >=0');
                else
                    obj.rng_random_stddev_ft = value;
                end
            end
            function set.rng_tau_s(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for range time correlation: rng_tau_s must be >=0');
                else
                    obj.rng_tau_s = value;
                end
            end
            function set.rng_bias_stddev_ft(obj, value)
                if(~isnumeric(value))
                    error('Invalid value for range bias: rng_bias_stddev_ft must be numeric');
                else
                    obj.rng_bias_stddev_ft = value;
                end
            end
             function set.rng_bias_switch(obj, value)
                if ~(value ==1 || value ==0)
                    error('Invalid value for range bias switch: rng_bias_switch must be 0 or 1');
                else
                    obj.rng_bias_switch = value;
                end
             end
             function set.rng_std_dev_gain(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for range standard deviation gain: rng_std_dev_gain must be >=0');
                else
                    obj.rng_std_dev_gain = value;
                end
            end
            function set.rngdot_random_stddev_ftps(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for range rate standard devation: rngdot_random_stddev_ftps must be >=0 ');
                else
                    obj.rngdot_random_stddev_ftps = value;
                end
            end
            function set.rngdot_tau_s(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for range rate time correlation: rngdot_tau_s must be >=0');
                else
                    obj.rngdot_tau_s  = value;
                end
            end
            function set.rngdot_bias_stddev_ftps(obj, value)
                if(~isnumeric(value))
                    error('Invalid value for range rate bias: rngdot_bias_stddev_ftps must be numeric');
                else
                    obj.rngdot_bias_stddev_ftps = value;
                end
            end
            function set.rngdot_delay_s(obj, value)
                if(~isnumeric(value)|| value < 0)
                    error('Invalid value for range rate delay: rngdot_delay_s must be >=0');
                else
                    obj.rngdot_delay_s = value;
                end
             end
             function set.rngdot_std_dev_gain(obj, value)
                if(~isnumeric(value)|| value < 0)
                    error('Invalid value for range rate standard deviation gain: rngdot_std_dev_gain must be >=0');
                else
                    obj.rngdot_std_dev_gain = value;
                end
            end
            function set.az_random_stddev_rad(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for azimuth standard deviation: az_random_stddev_rad must be >=0');
                else
                    obj.az_random_stddev_rad = value;
                end
            end
            function set.az_tau_s(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for azimuth time correlation: az_tau_s must be >=0');
                else
                    obj.az_tau_s = value;
                end
            end
            function set.az_bias_stddev_rad(obj, value)
                if(~isnumeric(value))
                    error('Invalid value for azimuth bias: az_bias_stddev_rad must be numeric');
                else
                    obj.az_bias_stddev_rad = value;
                end
            end
            function set.el_random_stddev_rad(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for elevation standard deviation: el_random_stddev_rad must be >=0');
                else
                    obj.el_random_stddev_rad = value;
                end
            end
            function set.el_tau_s(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for elevation time correlation: el_tau_s must be >=0');
                else
                    obj.el_tau_s = value;
                end
            end
            function set.el_bias_stddev_rad(obj, value)
                if(~isnumeric(value))
                    error('Invalid value for elevation bias: el_bias_stddev_rad must be numeric');
                else
                    obj.el_bias_stddev_rad = value;
                end
            end
            function set.azdot_random_stddev_radps (obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for azimuth rate standard deviation: azdot_random_stddev_radps must be >=0');
                else
                    obj.azdot_random_stddev_radps  = value;
                end
            end
            function set.azdot_tau_s(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for azimuth rate time correlation: azdot_tau_s must be >=0');
                else
                    obj.azdot_tau_s = value;
                end
            end
            function set.azdot_bias_stddev_radps(obj, value)
                if(~isnumeric(value))
                    error('Invalid value for azimuth rate bias: azdot_bias_stddev_radps must be numeric');
                else
                    obj.azdot_bias_stddev_radps = value;
                end
            end
            function set.eldot_random_stddev_radps(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for elevation rate standard deviation: eldot_random_stddev_radps must be >=0');
                else
                    obj.eldot_random_stddev_radps = value;
                end
            end
            function set.eldot_tau_s(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for elevation rate time correlation: eldot_tau_s must be >=0');
                else
                    obj.eldot_tau_s  = value;
                end
            end
            function set.eldot_bias_stddev_radps(obj, value)
                if(~isnumeric(value))
                    error('Invalid value for elevation rate bias: eldot_bias_stddev_radps must be numeric');
                else
                    obj.eldot_bias_stddev_radps = value;
                end
            end
            function set.sns_max_range_ft(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for max range: sns_max_range_ft must be >=0');
                else
                    obj.sns_max_range_ft = value;
                end
            end
            function set.sns_for_azimuth_deg(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for FOR azimuth: sns_for_azimuth_deg must be >=0');
                else
                    obj.sns_for_azimuth_deg = value;
                end
            end
            function set.sns_for_elevation_deg(obj, value)
                if(~isnumeric(value) || value < 0)
                    error('Invalid value for FOR elevation: sns_for_elevation_deg must be >=0');
                else
                    obj.sns_for_elevation_deg = value;
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
            obj.azdot_bias_radps = obj.azdot_bias_stddev_radps*(2*rand(1) - 1);
            obj.eldot_bias_radps = obj.eldot_bias_stddev_radps*(2*rand(1) - 1);                        

            % draw seeds for random error processes
            seeds = randi(4294967295,6); % 4294967295 = 2^32 - 1
            obj.seed1 = seeds(1);
            obj.seed2 = seeds(2);
            obj.seed3 = seeds(3);
            obj.seed4 = seeds(4);
            obj.seed5 = seeds(5);
            obj.seed6 = seeds(6);
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
                varName = setdiff( properties(this), { 'tunableParameterPrefix', ...
                    'reported_range_error_var_ft2', ...
                    'reported_azimuth_error_var_rad2', ...
                    'reported_elevation_error_var_rad2', ...
                    'reported_range_rate_error_var_fps2', ...
                    'reported_azimuth_rate_error_var_rps2', ...
                    'reported_elevation_rate_error_var_rps2' ...
                    'rng_bias_stddev_ft', ...
                    'rngdot_bias_stddev_ftps', ...
                    'az_bias_stddev_rad', ...
                    'azdot_bias_stddev_radps', ...
                    'el_bias_stddev_rad', ...
                    'eldot_bias_stddev_radps' ...
                            });
            end                        
            [varName, varValue] = this.getTunableParameters@Block( varName );
        end
    end        
end