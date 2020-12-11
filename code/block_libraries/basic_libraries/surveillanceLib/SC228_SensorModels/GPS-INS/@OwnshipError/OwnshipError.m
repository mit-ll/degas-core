classdef (Sealed = true) OwnshipError < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% OwnshipError: This Simulink block models a GPS/INS sensor according to 
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
     
     % X position properties
     x_random_stddev_ft= 37.8*DEGAS.m2ft;   % NACp = 8
     x_tau_s = 300;
     x_bias_stddev_ft = 0;
     
     % Y position properties
     y_random_stddev_ft = 37.8*DEGAS.m2ft;
     y_tau_s = 300;
     y_bias_stddev_ft = 0;

     % Altitude properties
     alt_random_stddev_ft = 0;
     alt_tau_s = 0;
     alt_bias_stddev_ft = 0;
     
     % X rate properties
     vx_random_stddev_ftps = 1.22*DEGAS.m2ft;   % NACv = 2
     vx_tau_s = 300;
     vx_bias_stddev_ftps = 0;

     % Y rate properties
     vy_random_stddev_ftps = 1.22*DEGAS.m2ft;
     vy_tau_s = 300;
     vy_bias_stddev_ftps = 0;
     
     % Altitude rate properties
     vz_random_stddev_ftps = 0;
     vz_tau_s = 0;
     vz_bias_stddev_ftps = 0;

     % Azimuth properties
     az_random_stddev_ftps2 = (1e-5)*DEGAS.g;
     az_tau_s = 3600;
     az_bias_stddev_ftps2 = 0;

     % Heading properties
     psi_random_stddev_rad = 0.4*DEGAS.deg2rad; 
     
     % Bank/roll properties
     phi_random_stddev_rad = 0.2*DEGAS.deg2rad;
     
     % Pitch properties
     theta_random_stddev_rad = 0.2*DEGAS.deg2rad;
     
     % Altitude quantization
     altQuant_ft = 1;
     
     % The bias values for the X, Y, Altitude positions, the X,
     % Y, Altitude rates, the heading, bank/roll, pitch angles and the 
     % roll-rate. These are set by the prepareProperties function of this 
     % class.     
     % Constant Biases
     x_bias_ft
     y_bias_ft
     alt_bias_ft
     vx_bias_ftps
     vy_bias_ftps
     vz_bias_ftps
     az_bias_ftps2
     psi_bias_rad = 0
     phi_bias_rad = 0
     dphi_bias_radps = 0
     
     % Enables the TSAA Error Model
     usePerfectAlt = false;
     
     % The seeds are used for noise generation. Normally, the user will
     % never have to set these values. They are set in the 
     % prepareProperties function of this class.      
     
     seed1
     seed2
     seed3
     seed4
     seed5
     seed6
     seed7
     seed8
     seed9
     seed10
        
    end % end properties
    
    properties(Dependent)
     % Reported error covariance
     reported_x_error_var_ft2
     reported_y_error_var_ft2
     reported_altitude_error_var_ft2
     reported_velocityx_error_var_ft2ps2
     reported_velocityy_error_var_ft2ps2
     reported_velocityD_error_var_ft2ps2
     reported_vertaccel_error_var_ft2ps4
     reported_heading_error_var_rad2
     reported_roll_error_var_rad2
    end
%% Getters
% These methods return the reported error values. The method does not have
% to be called explicitly, i.e. running
% "simObj.ac1OwnSens.reported_x_error_var_ft2" in the command line
% would call get.reported_x_error_var_ft2(this)    
    
    methods
        function val = get.reported_x_error_var_ft2(this)
            val = this.x_random_stddev_ft^2 + this.x_bias_stddev_ft^2;            
        end
        function val = get.reported_y_error_var_ft2(this)
            val = this.y_random_stddev_ft^2 + this.y_bias_stddev_ft^2;            
        end
        function val = get.reported_altitude_error_var_ft2(this)
            val = this.alt_random_stddev_ft^2 + this.alt_bias_stddev_ft^2;
        end
        function val = get.reported_velocityx_error_var_ft2ps2(this)
            val = this.vx_random_stddev_ftps^2 + this.vx_bias_stddev_ftps^2;
        end
        function val = get.reported_velocityy_error_var_ft2ps2(this)
            val = this.vy_random_stddev_ftps^2 + this.vy_bias_stddev_ftps^2;
        end
        function val = get.reported_velocityD_error_var_ft2ps2(this)
            val = this.vz_random_stddev_ftps^2 + this.vz_bias_stddev_ftps^2;
        end
        function val = get.reported_vertaccel_error_var_ft2ps4(this)
            val = this.az_random_stddev_ftps2^2 + this.az_bias_stddev_ftps2^2;
        end
        function val = get.reported_heading_error_var_rad2(this)
            val = this.psi_random_stddev_rad^2;
        end
        function val = get.reported_roll_error_var_rad2(this)
            val = this.phi_random_stddev_rad^2;
        end
    end
    properties(Dependent)
        reported_errorCovOwnshipError
    end
    methods
        function val = get.reported_errorCovOwnshipError(this)
            val = diag( [ this.reported_x_error_var_ft2 ...
                          this.reported_y_error_var_ft2 ...
                          this.reported_altitude_error_var_ft2 ...
                          this.reported_velocityy_error_var_ft2ps2 ...
                          this.reported_velocityx_error_var_ft2ps2 ...
                          this.reported_velocityD_error_var_ft2ps2 ...
                          this.reported_vertaccel_error_var_ft2ps4 ...
                          this.reported_heading_error_var_rad2 ...
                          this.reported_roll_error_var_rad2  ] );
        end
    end
    
    %% Constructor
    methods
        function obj = OwnshipError (tunableParameterPrefix,varargin)
            if( nargin < 1 )
                tunableParameterPrefix = '';
            end
            
            p = inputParser;
            % Required parameters
            addRequired(p,'tunableParameterPrefix',@ischar);
            
            addOptional(p, 'dt_s', obj.dt_s, @isnumeric);
            addOptional(p, 'x_random_stddev_ft', obj.x_random_stddev_ft, @isnumeric);
            addOptional(p, 'x_tau_s', obj.x_tau_s, @isnumeric);
            addOptional(p, 'x_bias_stddev_ft', obj.x_bias_stddev_ft, @isnumeric);
            addOptional(p, 'y_random_stddev_ft', obj.y_random_stddev_ft, @isnumeric);
            addOptional(p, 'y_tau_s', obj.y_tau_s, @isnumeric);
            addOptional(p, 'y_bias_stddev_ft', obj.y_bias_stddev_ft, @isnumeric);
            addOptional(p, 'alt_random_stddev_ft', obj.alt_random_stddev_ft, @isnumeric);
            addOptional(p, 'alt_tau_s', obj.alt_tau_s, @isnumeric);
            addOptional(p, 'alt_bias_stddev_ft', obj.alt_bias_stddev_ft, @isnumeric);
            addOptional(p, 'vx_random_stddev_ftps', obj.vx_random_stddev_ftps, @isnumeric);
            addOptional(p, 'vx_tau_s', obj.vx_tau_s, @isnumeric);
            addOptional(p, 'vx_bias_stddev_ft', obj.vx_bias_stddev_ftps, @isnumeric);
            addOptional(p, 'vy_random_stddev_ftps', obj.vy_random_stddev_ftps, @isnumeric);
            addOptional(p, 'vy_tau_s', obj.vy_tau_s, @isnumeric);
            addOptional(p, 'vy_bias_stddev_ft', obj.vy_bias_stddev_ftps, @isnumeric);
            addOptional(p, 'vz_random_stddev_ftps', obj.vz_random_stddev_ftps, @isnumeric);
            addOptional(p, 'vz_tau_s', obj.vz_tau_s, @isnumeric);
            addOptional(p, 'vz_bias_stddev_ft', obj.vz_bias_stddev_ftps, @isnumeric);
            addOptional(p, 'az_random_stddev_ftps2', obj.az_random_stddev_ftps2, @isnumeric);
            addOptional(p, 'az_tau_s', obj.az_tau_s, @isnumeric);
            addOptional(p, 'az_bias_stddev_ft', obj.az_bias_stddev_ftps2, @isnumeric);
            addOptional(p, 'psi_random_stddev_rad', obj.psi_random_stddev_rad, @isnumeric);
            addOptional(p, 'theta_random_stddev_rad', obj.theta_random_stddev_rad, @isnumeric);
            addOptional(p, 'phi_random_stddev_rad', obj.phi_random_stddev_rad, @isnumeric);
            addOptional(p, 'usePerfectAlt', obj.usePerfectAlt, @islogical);
            addOptional(p, 'altQuant_ft', obj.altQuant_ft, @isnumeric);
            
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
% explicitly, i.e. running "simObj.ac1OwnSens.dt_s = 1" in the command
% line will call set.dt_s(obj, value)

        function set.dt_s(obj, value)
            if(~isnumeric(value) || value <= 0)
                error('Invalid value for time step. dt_s must be a number greater than zero.');
            else
                obj.dt_s = value;
            end
        end
        function set.x_random_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for x standard deviation. x_random_stddev_ft must be a number greater than or equal to zero.');
            else
                obj.x_random_stddev_ft = value;
            end
        end
        function set.x_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value x time correlation. x_tau_s must be a number greater than or equal to zero.');
            else
                obj.x_tau_s = value;
            end
        end
        function set.x_bias_stddev_ft(obj, value)
            if(~isnumeric(value))
                error('Invalid value for x bias. x_bias_stddev_ft must be a number.');
            else
                obj.x_bias_stddev_ft = value;
            end
        end
        function set.y_random_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for y standard deviation. y_random_stddev_ft must be a number greater than or equal to zero.');
            else
                obj.y_random_stddev_ft = value;
            end
        end
       function set.y_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for y time correlation. y_tau_s must be a number greater than or equal to zero.');
            else
                obj.y_tau_s = value;
            end
       end
       function set.y_bias_stddev_ft(obj, value)
            if(~isnumeric(value))
                error('Invalid value for y bias. y_bias_stddev_ft must be a number.');
            else
                obj.y_bias_stddev_ft = value;
            end
       end  
       function set.alt_random_stddev_ft(obj, value)
           if(~isnumeric(value) || value < 0)
                error('Invalid value for altitude standard deviation. alt_random_stddev_ft must be a number greater than or equal to zero.');
           else
                obj.alt_random_stddev_ft = value;
           end
       end
       function set.alt_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for altitude time correlation. alt_tau_s must be a number greater than or equal to zero.');
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
       function set.vx_random_stddev_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for vx standard deviation. vx_random_stddev_ftps must be a number greater than or equal to zero.');
            else
                obj.vx_random_stddev_ftps = value;
            end
       end
       function set.vx_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for vx time correlation. vx_tau_s must be a number greater than or equal to zero.');
            else
                obj.vx_tau_s = value;
            end
       end
       function set.vx_bias_stddev_ftps(obj, value)
            if(~isnumeric(value))
                error('Invalid value for vx bias. vx_bias_stddev_ftps must be a number.');
            else
                obj.vx_bias_stddev_ftps = value;
            end
       end  
       function set.vy_random_stddev_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for vy deviation. vy_random_stddev_ftps must be a number greater than or equal to zero.');
            else
                obj.vy_random_stddev_ftps = value;
            end
       end  
       function set.vy_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for vy time correlation. vy_tau_s must be a number greater than or equal to zero.');
            else
                obj.vy_tau_s = value;
            end
       end  
       function set.vy_bias_stddev_ftps(obj, value)
            if(~isnumeric(value))
                error('Invalid value for vy bias. vy_bias_stddev_ftps must be a number.');
            else
                obj.vy_bias_stddev_ftps = value;
            end
       end  
       function set.vz_random_stddev_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for vz standard deviation. vz_random_stddev_ftps must be a number greater than or equal to zero.');
            else
                obj.vz_random_stddev_ftps = value;
            end
       end  
       function set.vz_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for vz time correlation. vz_tau_s must be a number greater than or equal to zero.');
            else
                obj.vz_tau_s = value;
            end
       end  
       function set.vz_bias_stddev_ftps(obj, value)
            if(~isnumeric(value))
                error('Invalid value for vz bias. vz_bias_stddev_ftps must be a number.');
            else
                obj.vz_bias_stddev_ftps = value;
            end
       end  
       function set.az_random_stddev_ftps2(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for azimuth standard deviation. az_random_stddev_ftps2 must be a number greater than or equal to zero.');
            else
                obj.az_random_stddev_ftps2 = value;
            end
       end  
       function set.az_tau_s(obj, value)
           if(~isnumeric(value) || value < 0)
                error('Invalid value for azimuth time correlation. az_tau_s must be a number greater than or equal to zero.');
           else
                obj.az_tau_s  = value;
           end
       end  
       function set.az_bias_stddev_ftps2(obj, value)
           if(~isnumeric(value))
                error('Invalid value for azimuth bias. az_bias_stddev_ftps2 must be a number.');
           else
                obj.az_bias_stddev_ftps2 = value;
           end
       end  
       function set.psi_random_stddev_rad(obj, value)
           if(~isnumeric(value) || value < 0)
                error('Invalid value for heading standard deviation. psi_random_stddev_rad must be a number greater than or equal to zero.');
           else
                obj.psi_random_stddev_rad = value;
           end
       end  
       function set.phi_random_stddev_rad(obj, value)
           if(~isnumeric(value) || value < 0)
                error('Invalid value for bank/roll standard deviation. phi_random_stddev_rad must be a number greater than or equal to zero.');
           else
                obj.phi_random_stddev_rad = value;
           end
       end
       function set.theta_random_stddev_rad(obj, value)
           if(~isnumeric(value) || value < 0)
                error('Invalid value for pitch standard deviation. theta_random_stddev_rad must be a number greater than or equal to zero.');
           else
                obj.theta_random_stddev_rad = value;
           end
       end  
       function set.usePerfectAlt(obj, value)
           if(~islogical(value))
                error('Invalid value for perfect alittude use. usePerfectAlt must be true or false.');
           else
                obj.usePerfectAlt = value;
           end
       end  
       function set.altQuant_ft(obj, value)
           if(~isnumeric(value) || value <= 0)
                error('Invalid value for altitude quantization. altQuant_ft must be a number greater than zero.');
           else
                obj.altQuant_ft = value;
           end
       end  
    end % End methods
    
    %%
    methods(Access = 'public')
        function prepareProperties(obj)
            
            % set biases
            
            obj.x_bias_ft = obj.x_bias_stddev_ft*(2*rand(1) - 1);
            obj.y_bias_ft = obj.y_bias_stddev_ft*(2*rand(1) - 1);
            obj.alt_bias_ft = obj.alt_bias_stddev_ft*(2*rand(1) - 1);
            obj.vx_bias_ftps = obj.vx_bias_stddev_ftps*(2*rand(1) - 1);
            obj.vy_bias_ftps = obj.vy_bias_stddev_ftps*(2*rand(1) - 1);
            obj.vz_bias_ftps = obj.vz_bias_stddev_ftps*(2*rand(1) - 1);
            obj.az_bias_ftps2 = obj.az_bias_stddev_ftps2*(2*rand(1) - 1);

            % draw seeds for random error processes
            
            seeds = randi(4294967295,6); % 4294967295 = 2^32 - 1
            obj.seed1 = seeds(1);
            obj.seed2 = seeds(2);
            obj.seed3 = seeds(3);
            obj.seed4 = seeds(4);
            obj.seed5 = seeds(5);
            obj.seed6 = seeds(6);
            obj.seed7 = seeds(7);
            obj.seed8 = seeds(8);
            obj.seed9 = seeds(9);
            obj.seed10 = seeds(10);
                                    
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
                    'reported_x_error_var_ft2', ...
                    'reported_y_error_var_ft2', ...
                    'reported_altitude_error_var_ft2', ...
                    'reported_velocityN_error_var_ft2ps2', ...
                    'reported_velocityE_error_var_ft2ps2', ...
                    'reported_velocityD_error_var_ft2ps2', ...
                    'reported_vertaccel_error_var_ft2ps4', ...
                    'reported_heading_error_var_rad2', ...
                    'reported_roll_error_var_rad2', ...
                    'reported_roll_rate_error_var_rad2ps2' ...
                    'x_bias_stddev_rad', ...
                    'y_bias_stddev_rad', ...
                    'alt_bias_stddev_ft', ...
                    'vx_bias_stddev_ftps', ...
                    'vy_bias_stddev_ftps', ...
                    'vz_bias_stddev_ftps', ...
                    'az_bias_stddev_ftps2', ...
                    'psi_bias_stddev_rad', ...
                    'phi_bias_stddev_rad', ...
                    'dphi_bias_stddev_radps', ...
                            });
            end                        
            
            [varName, varValue] = this.getTunableParameters@Block( varName );
        end
    end
        
end % End classef