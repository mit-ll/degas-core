classdef (Sealed = true) SimpleTrackedSurveillance < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% SimpleTrackedSurveillance: This Simulink block models tracked 
% surveillance per RTCA SC-228 MOPS DO-365 Table 2-20
    
    %%
    properties (GetAccess = 'public', SetAccess = 'public')               
    
     % These values determine the properties of the signals output by the
     % sensor
     % Suffix meanings:
     % _bias_stddev_*: Standard deviation of the error bias
     % _jitter_stddev: Standard deviation of the jitter of the error 
        
     % Horizontal position properties
     horizontal_position_bias_stddev_ft = 5;
     horizontal_position_jitter_stddev_ft = 0;
      
     % Vertical position properties
     vertical_position_bias_stddev_ft = 5;     % Standard deviation of the normally distrbuted component of vetical position bias
     vertical_position_bias_halfwidth_ft = 100; % Half-width of the uniformly distribution component of vertical position bias
     vertical_position_jitter_stddev_ft = 15;
     
     % Horizontal velocity properties
     horizontal_velocity_bias_stddev_fps = 1.5;
     horizontal_velocity_jitter_stddev_fps = 1.5;
     
     % Vertical velocity properties
     vertical_velocity_bias_stddev_fps = 2.5;
     vertical_velocity_jitter_stddev_fps = 2.5;
          
     % The bias values for the North, East, Down positions and the North,
     % East, Down velocities. These are set by the prepareProperties 
     % function of this class.     
     % Random biases sampled in prepareProperties:
     east_position_error_ft
     north_position_error_ft 
     vertical_position_error_ft
     east_velocity_error_fps
     north_velocity_error_fps
     vertical_velocity_error_fps
     
     % Error covariances     
     nVar_ft2
     eVar_ft2
     hVar_ft2
     dnVar_ft2ps2
     deVar_ft2ps2
     dhVar_ft2ps2
     
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
    
    %%
    methods
        function obj = SimpleTrackedSurveillance (tunableParameterPrefix,varargin)
            if( nargin < 1 )
                tunableParameterPrefix = '';
            end
            
            p = inputParser;
            % Required parameters
            addRequired(p,'tunableParameterPrefix',@ischar);
            
            addOptional(p, 'horizontal_position_bias_stddev_ft', obj.horizontal_position_bias_stddev_ft, @isnumeric);
            addOptional(p, 'vertical_position_bias_stddev_ft', obj.vertical_position_bias_stddev_ft, @isnumeric);
            addOptional(p, 'horizontal_position_jitter_stddev_ft', obj.horizontal_position_jitter_stddev_ft, @isnumeric);
            addOptional(p, 'vertical_position_bias_halfwidth_ft', obj.vertical_position_bias_halfwidth_ft, @isnumeric);
            addOptional(p, 'vertical_position_jitter_stddev_ft', obj.vertical_position_jitter_stddev_ft, @isnumeric);
            addOptional(p, 'horizontal_velocity_bias_stddev_fps', obj.horizontal_velocity_bias_stddev_fps, @isnumeric);
            addOptional(p, 'horizontal_velocity_jitter_stddev_fps', obj.horizontal_velocity_jitter_stddev_fps, @isnumeric);
            addOptional(p, 'vertical_velocity_bias_stddev_fps', obj.vertical_velocity_bias_stddev_fps, @isnumeric);
            addOptional(p, 'vertical_velocity_jitter_stddev_fps', obj.vertical_velocity_jitter_stddev_fps, @isnumeric)
            
            parse(p,tunableParameterPrefix,varargin{:});
            
            fieldsSet = intersect( fieldnames(p.Results), fieldnames(obj) );
            for i = 1:1:numel(fieldsSet)
                obj.(fieldsSet{i}) = p.Results.(fieldsSet{i});
            end
            
            obj.nVar_ft2 = obj.horizontal_position_bias_stddev_ft^2 + obj.horizontal_position_jitter_stddev_ft^2;
            obj.eVar_ft2 = obj.horizontal_position_bias_stddev_ft^2 + obj.horizontal_position_jitter_stddev_ft^2;
            obj.hVar_ft2 = obj.vertical_position_bias_stddev_ft^2 + 1/3*obj.vertical_position_bias_halfwidth_ft^2 + obj.vertical_position_jitter_stddev_ft^2;
            obj.dnVar_ft2ps2 = obj.horizontal_velocity_bias_stddev_fps^2 + obj.horizontal_velocity_jitter_stddev_fps^2;
            obj.deVar_ft2ps2 = obj.horizontal_velocity_bias_stddev_fps^2 + obj.horizontal_velocity_jitter_stddev_fps^2;
            obj.dhVar_ft2ps2 = obj.vertical_velocity_bias_stddev_fps^2 + obj.vertical_velocity_jitter_stddev_fps^2; 
            
        end % End constructor
%% Setters
% Setter functions set the value of the property of the object by calling
% the appropriate set function. The set functions have input handling built
% in so that the value the property is set to is valid. Like the
% aforementioned getter functions, the setter functions are not called
% explicitly, i.e. running 
% "simObj.ac1SimpSens.horizontal_position_bias_stddev_ft = 1" in the 
% command line will call 
% set.horizontal_position_bias_stddev_ft(obj, value)

        function set.horizontal_position_bias_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for horizontal position bias standard deviation. horizontal_position_bias_stddev_ft must be a number greater than or equal to zero.');
            else
                obj.horizontal_position_bias_stddev_ft = value;
            end
        end
        function set.vertical_position_bias_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for vertical position bias standard deviation. vertical_position_bias_stddev_ft must be a number greater than or equal to zero.');
            else
                obj.vertical_position_bias_stddev_ft = value;
            end
        end
        function set.horizontal_position_jitter_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for horizontal position jitter standard deviation. horizontal_position_jitter_stddev_ft must be a number greater than or equal to zero.');
            else
                obj.horizontal_position_jitter_stddev_ft = value;
            end
        end
        function set.vertical_position_bias_halfwidth_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for vertical position bias halfwidth. vertical_position_bias_halfwidth_ft must be a number greater than or equal to zero.');
            else
                obj.vertical_position_bias_halfwidth_ft = value;
            end
        end
        function set.vertical_position_jitter_stddev_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for vertical position jitter standard deviation. vertical_position_jitter_stddev_ft must be a number greater than or equal to zero.');
            else
                obj.vertical_position_jitter_stddev_ft = value;
            end
        end
        function set.horizontal_velocity_bias_stddev_fps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for horizontal velocity bias standard deviation. horizontal_velocity_bias_stddev_fps must be a number greater than or equal to zero.');
            else
                obj.horizontal_velocity_bias_stddev_fps = value;
            end
        end
        function set.horizontal_velocity_jitter_stddev_fps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for horizontal velocity jitter standard deviation. horizontal_velocity_jitter_stddev_fps must be a number greater than or equal to zero.');
            else
                obj.horizontal_velocity_jitter_stddev_fps = value;
            end
        end
        function set.vertical_velocity_bias_stddev_fps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for vertical velocity bias standard deviation. vertical_velocity_bias_stddev_fps must be a number greater than or equal to zero.');
            else
                obj.vertical_velocity_bias_stddev_fps = value;
            end
        end
        function set.vertical_velocity_jitter_stddev_fps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for vertical velocity jitter standard deviation. vertical_velocity_jitter_stddev_fps must be a number greater than or equal to zero.');
            else
                obj.vertical_velocity_jitter_stddev_fps = value;
            end
        end
    end % End methods
    
    %%
    methods(Access = 'public')
        function prepareProperties(obj)   
            vertical_error_mean = 2*(rand()-0.5)*obj.vertical_position_bias_halfwidth_ft;
            obj.vertical_position_error_ft = vertical_error_mean + obj.vertical_position_bias_stddev_ft*randn(1);
            
            obj.east_position_error_ft = obj.horizontal_position_bias_stddev_ft*randn(1); 
            obj.north_position_error_ft = obj.horizontal_position_bias_stddev_ft*randn(1);
            
            obj.east_velocity_error_fps = obj.horizontal_velocity_bias_stddev_fps*randn(1);
            obj.north_velocity_error_fps = obj.horizontal_velocity_bias_stddev_fps*randn(1); 
            
            obj.vertical_velocity_error_fps = obj.vertical_velocity_bias_stddev_fps*randn(1); 
 
            obj.nVar_ft2 = obj.horizontal_position_bias_stddev_ft^2 + obj.horizontal_position_jitter_stddev_ft^2;
            obj.eVar_ft2 = obj.horizontal_position_bias_stddev_ft^2 + obj.horizontal_position_jitter_stddev_ft^2;
            obj.hVar_ft2 = 1/3*obj.vertical_position_bias_halfwidth_ft^2 + obj.vertical_position_jitter_stddev_ft^2;
            obj.dnVar_ft2ps2 = obj.horizontal_velocity_bias_stddev_fps^2 + obj.horizontal_velocity_jitter_stddev_fps^2;
            obj.deVar_ft2ps2 = obj.horizontal_velocity_bias_stddev_fps^2 + obj.horizontal_velocity_jitter_stddev_fps^2;
            obj.dhVar_ft2ps2 = obj.vertical_velocity_bias_stddev_fps^2 + obj.vertical_velocity_jitter_stddev_fps^2; 
            
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
                varName = setdiff( properties(this), { 'tunableParameterPrefix' });
            end            
            
            % Exclude bias distribution parameters (not needed within model)
            varName = setdiff( varName, { ...
                'horizontal_position_bias_stddev_ft', ...
                'horizontal_velocity_bias_stddev_fps', ...
                'vertical_position_bias_halfwidth_ft', ...
                'vertical_position_bias_stddev_ft', ...
                'vertical_velocity_bias_stddev_fps' ...
                });
            
            [varName, varValue] = this.getTunableParameters@Block( varName );
        end
    end   
end % End classef