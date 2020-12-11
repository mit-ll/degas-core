classdef (Sealed = false) SC228_ActiveSurveillanceModel < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% SC228_ActiveSurveillanceModel: This Simulink block models an Active 
% Surveillance sensor according to RTCA SC-228 MOPS (DO-365 Appendix Q)
    %%
    properties (GetAccess = 'public', SetAccess = 'public')               
     % Values from DAA MOPS DO-365 Appendix Q 
     
     dt_s = 1; % Sensor simulation rate (s)
        
     % These values determine the properties of the signals output by the
     % sensor
     % Suffix meanings:
     % _random_stddev_: Standard deviation of the error
     % _tau_s: Time correlation of the signal in seconds
     % _bias_stddev_*: Bias of the error     
     
     % Range properties
     rng_random_stddev_ft = 15.24*DEGAS.m2ft;
     rng_tau_s = 1;
     rng_bias_stddev_ft = 38.1*DEGAS.m2ft;
     
     % Range-rate properties
     rngdot_random_stddev_ftps = 0*DEGAS.m2ft;
     rngdot_tau_s = 5;
     rngdot_bias_stddev_ftps = 0;
     
     % Bearing properties     
     psi_random_stddev_rad = 9*DEGAS.deg2rad;
     psi_tau_s = 1;
     psi_bias_stddev_rad = 0;
     
     % Bearing rate properties
     psidot_random_stddev_radps = 0*DEGAS.deg2rad;
     psidot_tau_s = 5;
     psidot_bias_stddev_radps = 0;

     % Altitude properties
     alt_random_stddev_ft = 0*DEGAS.m2ft;
     alt_tau_s = 1;
     alt_bias_stddev_ft = 0*DEGAS.m2ft;
     
     % Altitude rate properties
     altdot_random_stddev_ftps = 0*DEGAS.m2ft;
     altdot_tau_s = 5;
     altdot_bias_stddev_ftps = 0;
     
     sns_max_range_ft = 20*DEGAS.nm2ft; % Max detection range
     % Directional detection range
     sns_max_front_range_ft %Dependent on MOde C or Mode S. Set in prepareProperties.
     sns_max_side_range_ft
     sns_max_rear_range_ft
          
     %Lookup tables for bearing error
     bearing_Breakpoints_deg = [-9999, -15, -10, 10, 20, 9999]';
     bearing_Sigma_deg = [15, 15, 15, 9, 15, 15];
     bearing_Max_deg = [45, 45, 45, 27, 45, 45];
     
     % The bias values for the range, range-rate, bearing, bearing rate,
     % altitude, and altitude rate signals. These are set by the 
     % prepareProperties function of this class.     
     % Constant Biases
     rng_bias_ft;
     rngdot_bias_ftps;
     psi_bias_rad;
     psidot_bias_radps;
     alt_bias_ft;
     altdot_bias_ftps;
     
     updateRate_sec = 0.2; % Update rate of the sensor
     tauThreshold_sec = 60; %Update at 1hz if tau < tauThreshold; otherwise, update at updateRate
     
     intruder_mode = 0; %Mode C (=1) or Mode S (=0)
     probDetect; %Dependent on mode
     altQuant_ft; %Dependent on mode
     
     % Field of Regard limits
     FOR_elev_min_deg = -15;
     FOR_elev_max_deg = 20;
     
     % The seeds are used for noise generation. Normally, the user will
     % never have to set these values. They are set in the 
     % prepareProperties function of this class.      
     seed1
     seed2
     seed3
     seed4
     seed5
     seed6
     randProbSeed %Seed used to determine if detection occurs
        
     isEnabled = true; %Whether to enable the Active Surveillance sensor
     
    end % end properties
    
    properties(Dependent)
     % Reported error covariance
     reported_range_error_var_ft2
     reported_bearing_error_var_rad2
     reported_altitude_error_var_ft2
     reported_range_rate_error_var_ftps2
     reported_bearing_rate_error_var_rps2
     reported_vertical_rate_error_var_ftps2
    end
%% Getters
% These methods return the reported error values. The method does not have
% to be called explicitly, i.e. running
% "simObj.ac1ASTSens.reported_range_error_var_ft2" in the command line
% would call get.reported_range_error_var_ft2(this)    
    
    methods
        function val = get.reported_range_error_var_ft2(this)
            val = this.rng_random_stddev_ft^2 + this.rng_bias_stddev_ft^2;            
        end
        function val = get.reported_bearing_error_var_rad2(this)
            val = this.psi_random_stddev_rad^2 + this.psi_bias_stddev_rad^2;            
        end
        function val = get.reported_altitude_error_var_ft2(this)
            val = max(this.alt_random_stddev_ft^2 + this.alt_bias_stddev_ft^2, 1);
        end
        function val = get.reported_range_rate_error_var_ftps2(this)
            val = this.rngdot_random_stddev_ftps^2 + this.rngdot_bias_stddev_ftps^2;
        end
        function val = get.reported_bearing_rate_error_var_rps2(this)
            val = this.psidot_random_stddev_radps^2 + this.psidot_bias_stddev_radps^2;            
        end
        function val = get.reported_vertical_rate_error_var_ftps2(this)
            val = max(this.altdot_random_stddev_ftps^2 + this.altdot_bias_stddev_ftps^2, 0.01); 
        end        
    end
    properties(Dependent)
        reported_errorCovRBA % Range (ft), Bearing (rad), Alt (ft), Range rate (fps), bearing rate (rps), vert rate (ftps)
    end
    methods
        function val = get.reported_errorCovRBA(this)
            val = diag( [ this.reported_range_error_var_ft2 this.reported_bearing_error_var_rad2 this.reported_altitude_error_var_ft2...
                this.reported_range_rate_error_var_ftps2 this.reported_bearing_rate_error_var_rps2 this.reported_vertical_rate_error_var_ftps2 ] );
        end
    end
    
    %% Constructor
    methods
        function obj = SC228_ActiveSurveillanceModel (tunableParameterPrefix,varargin)
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
            addOptional(p, 'psi_random_stddev_rad', obj.psi_random_stddev_rad, @isnumeric);
            addOptional(p, 'psi_tau_s', obj.psi_tau_s, @isnumeric);
            addOptional(p, 'psi_bias_stddev_rad', obj.psi_bias_stddev_rad, @isnumeric);
            addOptional(p, 'psidot_random_stddev_radps', obj.psidot_random_stddev_radps, @isnumeric);
            addOptional(p, 'psidot_tau_s', obj.psidot_tau_s, @isnumeric);
            addOptional(p, 'psidot_bias_stddev_radps', obj.psidot_bias_stddev_radps, @isnumeric);
            addOptional(p, 'alt_random_stddev_ft', obj.alt_random_stddev_ft, @isnumeric);
            addOptional(p, 'alt_tau_s', obj.alt_tau_s, @isnumeric);
            addOptional(p, 'alt_bias_stddev_ft', obj.alt_bias_stddev_ft, @isnumeric);
            addOptional(p, 'altdot_random_stddev_ftps', obj.altdot_random_stddev_ftps, @isnumeric);
            addOptional(p, 'altdot_tau_s', obj.altdot_tau_s, @isnumeric);
            addOptional(p, 'altdot_bias_stddev_ftps', obj.altdot_bias_stddev_ftps, @isnumeric);
            addOptional(p, 'sns_max_range_ft', obj.sns_max_range_ft, @isnumeric);
            addOptional(p, 'intruder_mode', obj.intruder_mode, @isnumeric);
            addOptional(p, 'probDetect', obj.probDetect, @isnumeric);
            addOptional(p, 'bearing_Sigma_deg', obj.bearing_Sigma_deg , @isnumeric);
            addOptional(p, 'bearing_Breakpoints_deg', obj.bearing_Breakpoints_deg, @isnumeric);
            addOptional(p, 'bearing_Max_deg', obj.bearing_Max_deg, @isnumeric);
            addOptional(p, 'updateRate_sec', obj.updateRate_sec, @isnumeric);
            addOptional(p, 'tauThreshold_sec', obj.tauThreshold_sec, @isnumeric);
            addOptional(p, 'altQuant_ft', obj.altQuant_ft, @isnumeric);
            addOptional(p, 'FOR_elev_min_deg', obj.FOR_elev_min_deg, @isnumeric);
            addOptional(p, 'FOR_elev_max_deg', obj.FOR_elev_max_deg, @isnumeric);
            addOptional(p, 'isEnabled', obj.isEnabled, @islogical);
            
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
% explicitly, i.e. running "simObj.ac1ASTSens.dt_s = 1" in the command
% line will call set.dt_s(obj, value)

        function set.dt_s(obj, value)
            if(~isnumeric(value) || value <= 0)
                error('Invalid value for time step. dt_s must be a number greater than zero.');
            else
                obj.dt_s = value;
            end
        end
        function set.rng_random_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for range standard deviation. rng_random_stddev_ft must be a value greater than or equal to zero.');
            else
                obj.rng_random_stddev_ft = value;
            end
        end
        function set.rng_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for range time correlation. rng_tau_s must be a value greater than or equal to zero.');
            else
                obj.rng_tau_s = value;
            end
        end
        function set.rng_bias_stddev_ft(obj, value)
            if(~isnumeric(value))
                error('Invalid value for range. rng_bias_stddev_ft must be a number.');
            else
                obj.rng_bias_stddev_ft = value;
            end
        end
        function set.rngdot_random_stddev_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for range rate standard deviation. rngdot_random_stddev_ftps must be a value greater than or equal to zero.');
            else
                obj.rngdot_random_stddev_ftps = value;
            end
        end
        function set.rngdot_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for range rate time correlation. rngdot_tau_s must be a value greater than or equal to zero.');
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
        function set.psi_random_stddev_rad(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for heading standard deviation. psi_random_stddev_rad must be a value greater than or equal to zero.');
            else
                obj.psi_random_stddev_rad = value;
            end
        end
        function set.psi_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for heading time correlation. psi_tau_s must be a value greater than or equal to zero.');
            else
                obj.psi_tau_s = value;
            end
        end
        function set.psi_bias_stddev_rad(obj, value)
            if(~isnumeric(value))
                error('Invalid value for heading bias. psi_bias_stddev_rad must be a value greater than or equal to zero.');
            else
                obj.psi_bias_stddev_rad = value;
            end
        end
        function set.psidot_random_stddev_radps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for heading rate standard deviation. psidot_random_stddev_radps must be a value greater than or equal to zero.');
            else
                obj.psidot_random_stddev_radps = value;
            end
        end
        function set.psidot_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for heading rate time correlation. psidot_tau_s must be a value greater than or equal to zero.');
            else
                obj.psidot_tau_s = value;
            end
        end
        function set.psidot_bias_stddev_radps(obj, value)
            if(~isnumeric(value))
                error('Invalid value for heading rate bias. psidot_bias_stddev_radps must be a number.');
            else
                obj.psidot_bias_stddev_radps = value;
            end
        end
        function set.alt_random_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for altittude standard deviation. alt_random_stddev_ft must be a value greater than or equal to zero.');
            else
                obj.alt_random_stddev_ft = value;
            end
        end
        function set.alt_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for altitude time correlation. alt_tau_s must be a value greater than or equal to zero.');
            else
                obj.alt_tau_s = value;
            end
        end
        function set.alt_bias_stddev_ft(obj, value)
            if(~isnumeric(value))
                error('Invalid value for altitude bias. alt_bias_stddev_ft must be a number.');
            else
                obj.alt_bias_stddev_ft = value;
            end
        end
        function set.altdot_random_stddev_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for altitude rate standard deviation. altdot_random_stddev_ftps must be a value greater than or equal to zero.');
            else
                obj.altdot_random_stddev_ftps = value;
            end
        end
        function set.altdot_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for altitude rate time correlation. altdot_tau_s must be a value greater than or equal to zero.');
            else
                obj.altdot_tau_s = value;
            end
        end
        function set.altdot_bias_stddev_ftps(obj, value)
            if(~isnumeric(value))
                error('Invalid value for altitude rate bias. altdot_bias_stddev_ftps must be a number.');
            else
                obj.altdot_bias_stddev_ftps = value;
            end
        end
        function set.sns_max_range_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for max range. sns_max_range_ft must be a value greater than or equal to zero.');
            else
                obj.sns_max_range_ft = value;
            end
        end
        function set.intruder_mode(obj, value)
            if(~isnumeric(value) || value < 0 || value > 1)
                error('Invalid value for intruder mode. intruder_mode must be zero or one.');
            else
                obj.intruder_mode = value;
            end
        end
        function set.bearing_Sigma_deg(obj, value)
            if(~isnumeric(value) || ~ismatrix(value))
                error('Invalid values for bearing sigma. bearing_Sigma_deg must be a vector with numeric values.');
            else
                obj.checkBearingLookupTable(value)
                obj.bearing_Sigma_deg  = value;
            end
        end
        function set.bearing_Breakpoints_deg(obj, value)
            if(~isnumeric(value) || ~ismatrix(value))
                error('Invalid values for bearing breakpoints. bearing_Breakpoints_deg must be a vector with numeric values.');
            else
                obj.checkBearingLookupTable(value)
                obj.bearing_Breakpoints_deg = value;
            end
        end
        function set.bearing_Max_deg(obj, value)
            if(~isnumeric(value) || ~ismatrix(value))
                error('Invalid value for max bearing. bearing_Max_deg must be a vector with numeric values.');
            else
                obj.checkBearingLookupTable(value)
                obj.bearing_Max_deg = value;
            end
        end
        function set.updateRate_sec(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for update rate. updateRate_sec must be a value greater than or equal to zero.');
            else
                obj.updateRate_sec = value;
            end
        end
        function set.tauThreshold_sec(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for tau threshold. tauThreshold_sec must be a value greater than or equal to zero.');
            else
                obj.tauThreshold_sec = value;
            end
        end
        function set.FOR_elev_min_deg(obj, value)
            if(~isnumeric(value))
                error('Invalid value for min FOR elevation. FOR_elev_min_deg must be a value greater than or equal to zero.');
            else
                obj.checkElevation('min',value);
                obj.FOR_elev_min_deg = value;
            end
        end
        function set.FOR_elev_max_deg(obj, value)
            if(~isnumeric(value))
                error('Invalid value for max FOR elevation. FOR_elev_max_deg must be a value greater than or equal to zero.');
            else
                obj.checkElevation('max',value);
                obj.FOR_elev_max_deg = value;
            end
        end
        function set.isEnabled(obj, value)
            if(~islogical(value))
                error('Invalid value for enabled. isEnabled must be true or false.');
            else
                obj.isEnabled = value;
            end
        end
        function checkElevation(obj,minMax,value)
            if strcmp(minMax,'min')
                if(obj.FOR_elev_max_deg < value)
                    error('FOR_elev_min_deg must be < FOR_elev_max_deg');
                end
            elseif strcmp(minMax,'max')
                if(value < obj.FOR_elev_min_deg)
                    error('FOR_elev_max_deg must be > FOR_elev_min_deg');
                end
            end
        end
        % Check that the bearing lookup tables all have the same dimensions
        % Only issue warning in case user is trying to change the
        % dimensions for all of them. Throw error during prepareProperties
        % if dimensions are still different.
        function checkBearingLookupTable(obj,value)
            if numel(value) ~= numel(obj.bearing_Breakpoints_deg) ...
                    || numel(value) ~= numel(obj.bearing_Max_deg) ...
                    || numel(value) ~= numel(obj.bearing_Sigma_deg)
                warning('bearing_Breakpoints_deg, bearing_Max_deg, bearing_Sigma_deg must all have the same number of elements');
            end 
        end
    end % End methods 
    %%
    methods(Access = 'public')
        function prepareProperties(obj)
            % set biases
            obj.rng_bias_ft = obj.rng_bias_stddev_ft*(2*rand(1) - 1);
            obj.rngdot_bias_ftps = obj.rngdot_bias_stddev_ftps*(2*rand(1) - 1);
            obj.psi_bias_rad = obj.psi_bias_stddev_rad*(2*rand(1) - 1);
            obj.psidot_bias_radps = obj.psidot_bias_stddev_radps*(2*rand(1) - 1);
            obj.alt_bias_ft = obj.alt_bias_stddev_ft*(2*rand(1) - 1);
            obj.altdot_bias_ftps = obj.altdot_bias_stddev_ftps*(2*rand(1) - 1);                        

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
            
            % Check that the bearing lookup tables all have the same dimensions
            if numel(obj.bearing_Breakpoints_deg) ~= numel(obj.bearing_Max_deg) ...
                    || numel(obj.bearing_Max_deg) ~= numel(obj.bearing_Sigma_deg)
                error('bearing_Breakpoints_deg, bearing_Max_deg, bearing_Sigma_deg must all have the same number of elements');
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