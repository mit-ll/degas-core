classdef (Sealed = false) SC228_TrackedAdsbModel < SC228_AdsbModel
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% SC228_TrackedAdsbModel: Class that models an ADSB sensor being used with
% a tracker. Tracker errors are modeled after DO-365 Table 2-20.
    
    %%
    properties (GetAccess = 'public', SetAccess = 'public')               
     % Values from RTCA SC-228 DAA MOPS DO-365 Table 2-20
     % "Single-Source Integrated Track Performance
     
     % The standard deviation of the North and East position errors based 
     % on DAA MOPS DO-365 Table 2-20     
     N_stddev_ft = 900;
     E_stddev_ft = 900;
     
     % The standard deviation of the North and East rate errors based 
     % on RTCA SC-228 DAA MOPS DO-365 Table 2-20          
     Ndot_stddev_ftps = 30*DEGAS.kt2ftps;
     Edot_stddev_ftps = 30*DEGAS.kt2ftps;
    end % end properties
    
    %% Constructor
    methods
        function obj = SC228_TrackedAdsbModel(tunableParameterPrefix,varargin)
            if( nargin < 1 )
                tunableParameterPrefix = '';
            end
            
            p = inputParser;
            % Required parameters
            addRequired(p,'tunableParameterPrefix',@ischar);
            addParameter(p, 'dt_s', obj.dt_s, @isnumeric);
            addParameter(p, 'N_stddev_ft', obj.N_stddev_ft, @isnumeric);
            addParameter(p, 'E_stddev_ft', obj.E_stddev_ft, @isnumeric);
            addParameter(p, 'Ndot_stddev_ftps', obj.Ndot_stddev_ftps, @isnumeric);
            addParameter(p, 'Edot_stddev_ftps', obj.Edot_stddev_ftps, @isnumeric);
            
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
% explicitly, i.e. running "simObj.ac1TrkdAdsbSens.N_stddev_ft = 1" in the 
% command line will call set.N_stddev_ft(obj, value)        
        
        function set.N_stddev_ft(obj, value)
            if(value < 0)
                error('Invalid value for tracked northern standard deviation. N_stddev_ft must be a number greater than or equal to zero.');
            else
                obj.N_stddev_ft = value;
            end
        end
        function set.E_stddev_ft(obj, value)
            if(value < 0)
                error('Invalid value for tracked eastern standard deviation. E_stddev_ft must be a number greater than or equal to zero.');
            else
                obj.E_stddev_ft = value;
            end
        end
       function set.Ndot_stddev_ftps(obj, value)
            if(value < 0)
                error('Invalid value for tracked northern rate standard deviation. Ndot_stddev_ftps must be a number greater than or equal to zero.');
            else
                obj.Ndot_stddev_ftps = value;
            end
       end  
       function set.Edot_stddev_ftps(obj, value)
           if(value < 0)
               error('Invalid value for tracked eastern rate standard deviation. Edot_stddev_ftps must be a number greater than or equal to zero.');
           else
               obj.Edot_stddev_ftps = value;
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