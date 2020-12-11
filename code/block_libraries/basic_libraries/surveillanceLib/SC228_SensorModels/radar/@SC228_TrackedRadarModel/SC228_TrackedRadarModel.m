classdef (Sealed = false) SC228_TrackedRadarModel < SC228_RadarModel
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% SC228_TrackedRadarModel: This Simulink block models a radar sensor being
% used with a tracker. Tracker errors are modeled after DO-365 Table 2-20.
    
    %%
    properties (GetAccess = 'public', SetAccess = 'public')               
     % Values from DAA MOPS DO-365 Table 2-20 
     % "Single-Source Integrated Track Performance"
     
     % The standard deviation and bias of the azimuth, elevation, azimuth 
     % rate, and elevation rate errors based on the RTCA SC-228 DAA MOPS 
     % DO-365 Table 2-20        
     az_stddev_ft = 125*(10000 - DEGAS.nm2ft) + 250;
     az_bias_ft = 0;
     
     el_stddev_ft = 100*(10000 - DEGAS.nm2ft) + 150;
     el_bias_ft = 0;
     
     azdot_stddev_ftps = 100*(10000 - 1*DEGAS.nm2ft) + 50*DEGAS.kt2ftps;  
     azdot_bias_ftps = 0;
     azdot_tau_s = 0;
     
     eldot_stddev_ftps = 280*(10000 - 1*DEGAS.nm2ft) + 800/DEGAS.min2sec; %fpm ->fps
     eldot_bias_ftps = 0; 
     eldot_tau_s = 0;
    end % end properties
    
    %% Constructor
    methods
        function obj = SC228_TrackedRadarModel (tunableParameterPrefix,varargin)
            if( nargin < 1 )
                tunableParameterPrefix = '';
            end
            
            p = inputParser;
            % Required parameters
            addRequired(p, 'tunableParameterPrefix',@ischar);
            addOptional(p, 'dt_s', obj.dt_s, @isnumeric);
            addOptional(p, 'az_stddev_ft', obj.az_stddev_ft, @isnumeric);
            addOptional(p, 'az_bias_ft', obj.az_bias_ft, @isnumeric);
            addOptional(p, 'el_stddev_ft', obj.el_stddev_ft, @isnumeric);
            addOptional(p, 'el_bias_ft', obj.el_bias_ft, @isnumeric);
            addOptional(p, 'azdot_stddev_ftps', obj.azdot_stddev_ftps, @isnumeric);
            addOptional(p, 'azdot_bias_ftps', obj.azdot_bias_ftps, @isnumeric);
            addOptional(p, 'azdot_tau_s', obj.azdot_tau_s, @isnumeric);
            addOptional(p, 'eldot_stddev_ftps', obj.eldot_stddev_ftps, @isnumeric);
            addOptional(p, 'eldot_bias_ftps', obj.eldot_bias_ftps, @isnumeric);
            addOptional(p, 'eldot_tau_s', obj.eldot_tau_s, @isnumeric);
            
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
% explicitly, i.e. running "simObj.ac1TrkdRdrSens.az_stddev_ft = 1" in the
% command line will call set.az_stddev_ft(obj, value)        

        function set.az_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for azimuth standard deviation. az_stddev_ft must be a number greater than or equal to zero.');
            else
                obj.az_stddev_ft = value;
            end
        end
        function set.az_bias_ft(obj, value)
            if(~isnumeric(value))
                error('Invalid value for azimuth bias. az_bias_ft must be a number');
            else
                obj.az_bias_ft = value;
            end
        end
        function set.el_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for elevation standard deviation. el_stddev_ft must be a number greater than or equal to zero.');
            else
                obj.el_stddev_ft = value;
            end
        end
        function set.el_bias_ft(obj, value)
            if(~isnumeric(value))
                error('Invalid value for elevation bias. el_bias_ft must be a number');
            else
                obj.el_bias_ft = value;
            end
        end
        function set.azdot_stddev_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for azimuth rate standard deviation. azdot_stddev_ftps must be a number greater than or equal to zero.');
            else
                obj.azdot_stddev_ftps = value;
            end
        end
        function set.azdot_bias_ftps(obj, value)
            if(~isnumeric(value))
                error('Invalid value for azimuth rate bias. azdot_bias_ftps must be a number');
            else
                obj.azdot_bias_ftps = value;
            end
        end
        function set.azdot_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for azimuth rate time correlation. azdot_tau_s must be a number greater than or equal to zero.');
            else
                obj.azdot_tau_s = value;
            end
        end
        function set.eldot_stddev_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for elevation rate standard deviation. eldot_stddev_ftps must be a number greater than or equal to zero.');
            else
                obj.eldot_stddev_ftps = value;
            end
        end
        function set.eldot_bias_ftps(obj, value)
            if(~isnumeric(value))
                error('Invalid value for elevation rate bias. eldot_bias_ftps must be a number.');
            else
                obj.eldot_bias_ftps = value;
            end
        end
        function set.eldot_tau_s(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for elevation rate time correlation. eldot_tau_s must be a number greater than or equal to zero.');
            else
                obj.eldot_tau_s = value;
            end
        end
    end % End methods
    
    %%
    methods(Access = 'public')
        function prepareProperties(obj)
            % draw seeds for random error processes
            seeds = randi(4294967295,12); % 4294967295 = 2^32 - 1
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