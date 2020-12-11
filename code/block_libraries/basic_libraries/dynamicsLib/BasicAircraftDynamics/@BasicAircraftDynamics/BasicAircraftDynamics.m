classdef (Sealed = true) BasicAircraftDynamics < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% BasicAircraftDynamics: Simulates the basic 6 degree-of-freedom dynamics 
% of an aircraft. Aircraft dynamic performance constraints can be defined 
% via the tunable parameters available in the class. 
    
    properties (GetAccess = 'public', SetAccess = 'public')
        % Initial Conditions
        v_ftps                          = 100; % Initial velocity
        N_ft                            = 0;   % Initial north position
        E_ft                            = 0;   % Initial east position
        h_ft                            = 1000;% Initial altitude
        psi_rad                         = 0;   % Initial heading
        theta_rad                       = 0;   % Initial pitch angle
        phi_rad                         = 0;   % Initial bank angle
        a_ftpss                         = 0;   % Initial acceleration

        % ENU Coordinate System
        lat0_rad                        = 0;   % Initial latitude
        lon0_rad                        = 0;   % Initial longitude
        alt0_ft                         = 1000;% Initial altitude
    end % end properties        

    properties % dynamics constraints properties
        con @ dynamicsConstraints
    end  

    % Aliases for initial conditions with readable names    
    properties( Dependent )
        heading_rad;     % Initial heading
        pitchAngle_rad;  % Initial pitch angle
        bankAngle_rad;   % Initial bank angle
    end
%% Getters
% These methods return the reported error values. The method does not have
% to be called explicitly, i.e. running
% "simObj.ac1Dyn.heading_rad" in the command line
% would call get.heading_rad(this)       

    methods
        function value = get.heading_rad( this )
            value = this.psi_rad;
        end
        function set.heading_rad( this, value )
            this.psi_rad = value;
        end
        function value = get.pitchAngle_rad( this )
            value = this.theta_rad;
        end
        function set.pitchAngle_rad( this, value )
            this.theta_rad = value;
        end
        function value = get.bankAngle_rad( this )
            value = this.phi_rad;
        end
        function set.bankAngle_rad( this, value )
            this.phi_rad = value;
        end        
    end    
    
    %%
    methods
        function obj = BasicAircraftDynamics (tunableParameterPrefix,varargin)
            if( nargin < 1 )
                tunableParameterPrefix = '';
            end
            
            p = inputParser;
            % Required Parameters
            addRequired(p,'tunableParameterPrefix',@ischar);
            % Initial Conditions
            addOptional(p,'v_ftps',obj.v_ftps,@isnumeric);
            addOptional(p,'N_ft',obj.N_ft,@isnumeric);
            addOptional(p,'E_ft',obj.E_ft,@isnumeric);
            addOptional(p,'h_ft',obj.h_ft,@isnumeric);
            addOptional(p,'psi_rad',obj.psi_rad,@isnumeric);
            addOptional(p,'theta_rad',obj.theta_rad,@isnumeric);
            addOptional(p,'phi_rad',obj.phi_rad,@isnumeric);
            addOptional(p,'a_ftpss',obj.a_ftpss,@isnumeric);
            
            % constraints
            obj.con = dynamicsConstraints();
            
            % ENU Coordinate System
            addOptional(p,'lat0_rad',obj.lat0_rad,@isnumeric);
            addOptional(p,'lon0_rad',obj.lon0_rad,@isnumeric);
            addOptional(p,'alt0_ft',obj.alt0_ft,@isnumeric);
       
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
% explicitly, i.e. running "simObj.ac1Dyn.v_ftps = 1" in the command
% line will call set.v_ftps(obj, value)

        function set.v_ftps(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for velocity: v_ftps must be >=0');
            else
                obj.v_ftps = value;
            end
        end
         function set.N_ft(obj, value)
            if(~isnumeric(value))
                error('Invalid value for north position: N_ft must be numeric');
            else
                obj.N_ft = value;
            end
         end
         function set.E_ft(obj, value)
            if(~isnumeric(value))
                error('Invalid value for east position: E_ft must be numeric');
            else
                obj.E_ft = value;
            end
         end
         function set.h_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for height: h_ft must be >=0');
            else
                obj.h_ft = value;
            end
         end
         function set.psi_rad(obj, value)
            if(~isnumeric(value))
                error('Invalid value for heading: psi_rad must be numeric');
            else
                obj.psi_rad = value;
            end
         end
         function set.theta_rad(obj, value)
            if(~isnumeric(value))
                error('Invalid value for pitch: theta_rad must be numeric');
            else
                obj.theta_rad = value;
            end
         end
         function set.phi_rad(obj, value)
            if(~isnumeric(value))
                error('Invalid value for roll: phi_rad must be numeric');
            else
                obj.phi_rad = value;
            end
         end
         function set.a_ftpss(obj, value)
            if(~isnumeric(value))
                error('Invalid value for acceleration: a_ftpss must be numeric');
            else
                obj.a_ftpss = value;
            end
         end
         function set.lat0_rad(obj, value)
            if(~isnumeric(value))
                error('Invalid value for iniital latitude: lat0_rad must be numeric');
            else
                obj.lat0_rad = value;
            end
         end
         function set.lon0_rad(obj, value)
            if(~isnumeric(value))
                error('Invalid value for initial longitude: lon0_rad must be numeric');
            else
                obj.lon0_rad = value;
            end
        end
        function set.alt0_ft(obj, value)
            if(~isnumeric(value) || value < 0)
                error('Invalid value for initial altitude: alt0_ft must be numeric');
            else
                obj.alt0_ft = value;
            end
        end  
    end % End methods
end % End classef