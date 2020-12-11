classdef (Sealed = false) SC228_AdsbModel < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% SC228_AdsbModel: Class that simulates an ADSB sensor according to RTCA 
% SC-228 MOPS (DO-365 Appendix Q)
    
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
     
     % North position properties
     N_random_stddev_ft = 75.6*DEGAS.m2ft;
     N_tau_s = 300;
     N_bias_stddev_ft = 0;
     
     % East position properties
     E_random_stddev_ft = 75.6*DEGAS.m2ft;
     E_tau_s = 300;
     E_bias_stddev_ft = 0;
     
     % Down position properties
     D_random_stddev_ft = 0;
     D_tau_s = 0;
     D_bias_stddev_ft = 0;
      
     % North rate properties
     Ndot_random_stddev_ftps = 1.22*DEGAS.m2ft;
     Ndot_tau_s = 300;
     Ndot_bias_stddev_ftps = 0;

     % East rate properties
     Edot_random_stddev_ftps = 1.22*DEGAS.m2ft;
     Edot_tau_s = 300;
     Edot_bias_stddev_ftps = 0; 
    
     % Down rate properties
     %Laplacian variances = 2b^2. The 95_bound = 1.96 * sigma. Together, b
     %= 95_bound/(sqrt(2) * 1.96)
     Ddot_random_stddev_ftps = 2*(5.6/(sqrt(2)*1.96))^2; 
     Ddot_tau_s = 300;
     Ddot_bias_stddev_ftps = 0;
               
     sns_max_range_ft =  20*DEGAS.nm2ft; % Max detection range
     rangeThreshold_ft = 10*DEGAS.nm2ft; % Range at which detection probabilities change
     
     %Probability of detecting a single report. Over any 3 (or 7) sec,
     %probability of at least 1 hit is 95%.
     probOneHit_3sec = 1-.05^(1/3); %Dividing by 30 or 70 to represent deciseconds
     probOneHit_7sec = 1-.05^(1/7);
     
     % The bias values for the North, East, Down positions and the North,
     % East, Down rates. These are set by the prepareProperties function of
     % this class.
     
     N_bias_ft
     E_bias_ft
     D_bias_ft 
     Ndot_bias_ftps
     Edot_bias_ftps
     Ddot_bias_ftps
     
     altQuant_ft = 25; %Dependent on mode - needs to be the same as the TCAS one. Set in SC228_ActiveSurveillanceModel.m.
     
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
     randProbSeed
     avionicsSeed
        
     % These properties control ADSB behavior
     usePerfectAlt = false; % Enables the TSAA error model
     isEnabled = true; % If true, the ADSB sensor is enabled.
     
    end % end properties
    
    properties(Dependent)
     % reported error covariance
     reported_N_error_var_ft2
     reported_E_error_var_ft2
     reported_D_error_var_ft2
     reported_Ndot_error_var_ft2ps2
     reported_Edot_error_var_ft2ps2
     reported_Ddot_error_var_ft2ps2
    end
%% Getters
% These methods return the reported error values. The method does not have
% to be called explicitly, i.e. running
% "simObj.ac1AdsbSens.reported_N_error_var_ft2" in the command line
% would call get.reported_N_error_var_ft2(this)

    methods
        function val = get.reported_N_error_var_ft2(this)
            val = this.N_random_stddev_ft^2 + this.N_bias_stddev_ft^2;            
        end
        function val = get.reported_E_error_var_ft2(this)
            val = this.E_random_stddev_ft^2 + this.E_bias_stddev_ft^2;
        end
        function val = get.reported_D_error_var_ft2(this)
            val = max(this.D_random_stddev_ft^2 + this.D_bias_stddev_ft^2, 1);
        end
        function val = get.reported_Ndot_error_var_ft2ps2(this)
            val = this.Ndot_random_stddev_ftps^2 + this.Ndot_bias_stddev_ftps^2;
        end
        function val = get.reported_Edot_error_var_ft2ps2(this)
            val = this.Edot_random_stddev_ftps^2 + this.Edot_bias_stddev_ftps^2;            
        end       
        function val = get.reported_Ddot_error_var_ft2ps2(this)
            val = this.Ddot_random_stddev_ftps^2 + this.Ddot_bias_stddev_ftps^2;            
        end  
    end
    properties(Dependent)
        reported_errorCovNED
    end
    methods
        function val = get.reported_errorCovNED(this)
            val = diag( [ this.reported_N_error_var_ft2 this.reported_E_error_var_ft2 this.reported_D_error_var_ft2 ...
                this.reported_Ndot_error_var_ft2ps2 this.reported_Edot_error_var_ft2ps2 this.reported_Ddot_error_var_ft2ps2] );
        end
    end
    
    %% Constructor
    methods
        function obj = SC228_AdsbModel(tunableParameterPrefix,varargin)
            if( nargin < 1 )
                tunableParameterPrefix = '';
            end
            
            p = inputParser;
            % Required parameters
            addRequired(p,'tunableParameterPrefix',@ischar);
            addOptional(p, 'dt_s', obj.dt_s, @isnumeric);
            addOptional(p, 'N_random_stddev_ft', obj.N_random_stddev_ft, @isnumeric);
            addOptional(p, 'N_tau_s', obj.N_tau_s, @isnumeric);
            addOptional(p, 'N_bias_stddev_ft', obj.N_bias_stddev_ft, @isnumeric);
            addOptional(p, 'E_random_stddev_ft', obj.E_random_stddev_ft, @isnumeric);
            addOptional(p, 'E_tau_s', obj.E_tau_s, @isnumeric);
            addOptional(p, 'E_bias_stddev_ft', obj.E_bias_stddev_ft, @isnumeric);
            addOptional(p, 'D_random_stddev_ft', obj.D_random_stddev_ft, @isnumeric);
            addOptional(p, 'D_tau_s', obj.D_tau_s, @isnumeric);
            addOptional(p, 'D_bias_stddev_ft', obj.D_bias_stddev_ft, @isnumeric);
            addOptional(p, 'Ndot_random_stddev_ftps', obj.Ndot_random_stddev_ftps, @isnumeric);
            addOptional(p, 'Ndot_tau_s', obj.Ndot_tau_s, @isnumeric);
            addOptional(p, 'Ndot_bias_stddev_ftps', obj.Ndot_bias_stddev_ftps, @isnumeric);
            addOptional(p, 'Edot_random_stddev_ftps', obj.Edot_random_stddev_ftps, @isnumeric);
            addOptional(p, 'Edot_tau_s', obj.Edot_tau_s, @isnumeric);
            addOptional(p, 'Edot_bias_stddev_ftps', obj.Edot_bias_stddev_ftps, @isnumeric);
            addOptional(p, 'Ddot_random_stddev_ftps', obj.Ddot_random_stddev_ftps, @isnumeric);
            addOptional(p, 'Ddot_tau_s', obj.Ddot_tau_s, @isnumeric);
            addOptional(p, 'Ddot_bias_stddev_ftps', obj.Ddot_bias_stddev_ftps, @isnumeric);
            addOptional(p, 'sns_max_range_ft', obj.sns_max_range_ft, @isnumeric);
            addOptional(p, 'probOneHit_3sec', obj.probOneHit_3sec, @isnumeric);
            addOptional(p, 'probOneHit_7sec', obj.probOneHit_7sec, @isnumeric);
            addOptional(p, 'rangeThreshold_ft', obj.rangeThreshold_ft, @isnumeric);
            addOptional(p, 'altQuant_ft', obj.altQuant_ft, @isnumeric);
            addOptional(p, 'usePerfectAlt', obj.usePerfectAlt, @islogical);
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
% explicitly, i.e. running "simObj.ac1AdsbSens.dt_s = 1" in the command
% line will call set.dt_s(obj, value)

        function set.dt_s(obj, value)
            if(~isnumeric(value) || value <= 0)
                error('Invalid value for time step. dt_s must be a number greater than zero.');
            else
                obj.dt_s = value;
            end
        end
        function set.N_random_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for northern standard deviation. N_random_stddev_ft must be a number greater than or equal to zero.');
            else
                obj.N_random_stddev_ft = value;
            end
        end
        function set.N_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value northern time correlation. N_tau_s must be a number greater than or equal to zero.');
            else
                obj.N_tau_s = value;
            end
        end
        function set.N_bias_stddev_ft(obj, value)
            if(~isnumeric(value))
                error('Invalid value for northern bias. N_bias_stddev_ft must be a number.');
            else
                obj.N_bias_stddev_ft = value;
            end
        end
        function set.E_random_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                    error('Invalid value for eastern standard deviation. E_random_stddev_ft must be a number greater than or equal to zero.');
            else
                obj.E_random_stddev_ft = value;
            end
        end
       function set.E_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for eastern time correlation. E_tau_s must be a number greater than or equal to zero.');
            else
                obj.E_tau_s = value;
            end
       end
       function set.E_bias_stddev_ft(obj, value)
            if(~isnumeric(value))
                error('Invalid value for eastern bias. E_bias_stddev_ft must be a number.');
            else
                obj.E_bias_stddev_ft = value;
            end
       end  
       function set.D_random_stddev_ft(obj, value)
           if(~isnumeric(value) || value < 0)
                error('Invalid value for standard deviation. D_random_stddev_ft must be a number greater than or equal to zero.');
           else
                obj.D_random_stddev_ft = value;
           end
       end
       function set.D_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for time correlation. D_tau_s must be a number greater than or equal to zero.');
            else
                obj.D_tau_s = value;
            end
       end
       function set.D_bias_stddev_ft(obj, value)
           if(~isnumeric(value))
               error('Invalid value for bias. D_bias_stddev_ft must be a number.');
           else
               obj.D_bias_stddev_ft = value;
           end
       end
       function set.Ndot_random_stddev_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for northern rate standard deviation. Ndot_random_stddev_ftps must be a number greater than or equal to zero.');
            else
                obj.Ndot_random_stddev_ftps = value;
            end
       end
       function set.Ndot_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for northern rate time correlation. Ndot_tau_s must be a number greater than or equal to zero.');
            else
                obj.Ndot_tau_s = value;
            end
       end
       function set.Ndot_bias_stddev_ftps(obj, value)
            if(~isnumeric(value))
                error('Invalid value for northern rate bias. Ndot_bias_stddev_ftps must be a number.');
            else
                obj.Ndot_bias_stddev_ftps = value;
            end
       end  
       function set.Edot_random_stddev_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for eastern rate standard deviation. Edot_random_stddev_ftps must be a number greater than or equal to zero.');
            else
                obj.Edot_random_stddev_ftps = value;
            end
       end
       function set.Edot_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for eastern rate time correlation. Edot_tau_s must be a number greater than or equal to zero.');
            else
                obj.Edot_tau_s = value;
            end
       end
       function set.Edot_bias_stddev_ftps(obj, value)
            if(~isnumeric(value))
                error('Invalid value for eastern rate bias. Edot_bias_stddev_ftps must be a number.');
            else
                obj.Edot_bias_stddev_ftps = value;
            end
       end  
       function set.Ddot_random_stddev_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for rate standard deviation. Ddot_random_stddev_ftps must be a number greater than or equal to zero.');
            else
                obj.Ddot_random_stddev_ftps = value;
            end
       end  
       function set.Ddot_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for time correlation. Ddot_tau_s must be a number greater than or equal to zero.');
            else
                obj.Ddot_tau_s = value;
            end
       end  
       function set.Ddot_bias_stddev_ftps(obj, value)
            if(~isnumeric(value))
                error('Invalid value for rate bias. Ddot_bias_stddev_ftps must be a number.');
            else
                obj.Ddot_bias_stddev_ftps = value;
            end
       end  
       function set.sns_max_range_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for max range. sns_max_range_ft must be a number greater than or equal to zero.');
            else
                obj.sns_max_range_ft = value;
            end
       end  
       function set.probOneHit_3sec(obj, value)
            if(~isnumeric(value) || value < 0 || value > 1)
                error('Invalid value for probability of one hit (3 sec). probOneHit_3sec must be a number greater than or equal to zero and less than or equal to one.');
            else
                obj.probOneHit_3sec = value;
            end
       end  
       function set.probOneHit_7sec(obj, value)
            if(~isnumeric(value) || value < 0 || value > 1)
                error('Invalid value for probability of one hit (7 sec). probOneHit_7sec must be a number greater than or equal to zero and less than or equal to one.');
            else
                obj.probOneHit_7sec = value;
            end
       end  
       function set.rangeThreshold_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for range threshold. rangeThreshold_ft must be a number greater than or equal to zero.');
            else
                obj.rangeThreshold_ft = value;
            end
       end  
       function set.usePerfectAlt(obj, value)
            if(~islogical(value))
                error('Invalid value for perfect altitude use. usePerfectAlt must be true or false.');
            else
                obj.usePerfectAlt = value;
            end
       end  
       function set.isEnabled(obj, value)
            if(~islogical(value))
                error('Invalid value for enabled. isEnabled must be true or false.');
            else
                obj.isEnabled = value;
            end
       end  
    end % End methods
    
    %%
    methods(Access = 'public')
        function prepareProperties(obj)

            % set biases
            
            obj.N_bias_ft = obj.N_bias_stddev_ft*(2*rand(1) - 1);
            obj.E_bias_ft = obj.E_bias_stddev_ft*(2*rand(1) - 1);
            obj.D_bias_ft = obj.D_bias_stddev_ft*(2*rand(1) - 1);
            obj.Ndot_bias_ftps = obj.Ndot_bias_stddev_ftps*(2*rand(1) - 1);
            obj.Edot_bias_ftps = obj.Edot_bias_stddev_ftps*(2*rand(1) - 1);
            obj.Ddot_bias_ftps = obj.Ddot_bias_stddev_ftps*(2*rand(1) - 1);
            
            % draw seeds for random error processes
            
            seeds = randi(4294967295,12); % 4294967295 = 2^32 - 1
            obj.seed1 = seeds(1);
            obj.seed2 = seeds(2);
            obj.seed3 = seeds(3);
            obj.seed4 = seeds(4);
            obj.seed5 = seeds(5);
            obj.seed6 = seeds(6);
            obj.seed7 = seeds(7);
            obj.seed8 = seeds(8);
            obj.randProbSeed = seeds(9);
            obj.avionicsSeed = seeds(10);
                                    
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
                    'reported_N_error_var_ft2', ...
                    'reported_E_error_var_ft2', ...
                    'reported_Ndot_error_var_ft2ps2', ...
                    'reported_Edot_error_var_ft2ps2', ...
                    'N_bias_stddev_ft', ...
                    'E_bias_stddev_ft', ...
                    'Ndot_bias_stddev_ftps', ...
                    'Edot_bias_stddev_ftps', ...
                            });
            end                        
            
            [varName, varValue] = this.getTunableParameters@Block( varName );
        end
    end
        
end % End classef