classdef DEGAS  < hgsetget & matlab.mixin.Copyable & matlab.mixin.Heterogeneous
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% DEGAS: The base class for the DEGAS simulation framework. It contains 
% properties that are useful for converting units and functions that can 
% be called by derived classes to perform actions before and after running 
% an end-to-end simulation.
%
% All DEGAS objects know how to go up the hierarchy and call the
% prepareSim method of all DEGAS objects to set the values of a Real Time
% Parameters structure, or to go up the hierarchy and call the
% onSimulationComplete method to notify objects that they are free to
% extract any simulation results as desired.
     
    %	Unit Conversions:
	
		properties (Constant, Hidden)

			%	Distance:
				nm2ft =  6076.1154855643;			% nautical miles -> feet [ft/NM]	unitsratio('ft','nm')
				m2ft  =     3.28083989501312;		% meter to ft conversion [ft/m]		unitsratio('ft','m')
				ft2m  =     0.3048;					% feet to meter conversion [m/ft]	unitsratio('m','ft')
			
			%	Speed:
				kt2ftps =   1.6878098571012;		% knots -> ft/sec					unitsratio('ft','nm')/(3600 sec/hr)
                ftps2kt =   0.592484;               % ft/sec -> knots                   unitsratio('nm','ft')*(3600 sec/hr)
			
			%	Angles:
				rad2deg =  57.2957795130823;		% degrees -> radians				unitsratio('deg','rad')
				deg2rad =   0.0174532925199433;		% degrees -> radians				unitsratio('rad','deg')
			
			%	Time:
				sec2min =   0.0166666666666667;		% seconds -> minutes (1/60 min/sec)
                min2sec =   60;                     % minutes -> seconds (60 sec/min)
			
			%	Constants of nature:
				g					= 32.17;		% gravity (ft/s/s)
				speedOfLight_fps	= 983514000;	% Speed of light (ft/s)
			
        end
    %	Notifications that all DEGAS objects can handle:
		methods			
			% Override Block.prepareSim calls setDegasTunableParameters			
			function prepareSim(obj)
			% DEGAS.prepareSim 
			%
			% Put aircraft parameters where Simulink model can find them
			%
			%
			%  Syntax:
			%
			%  aircraft.prepareSim() 
			%  
			%		Create variables for all aircraft parameters 
			%		in the base workspace  
			%
			%  Description:
			%
			%  The method DEGAS.prepareSim simply calls DEGAS.prepareSim
			%  on all its component objects (properties) that are of type
			%  DEGAS.  The override Block.prepareSim takes care of setting
			%  real time parameters from any Block objects reached in this
			%  walk of the object tree.  
			%          

				parameterNames = fieldnames(obj); % Get all parameter names
				for i=1:1:length(parameterNames) % Loop over all parameters
					if isa(obj.(parameterNames{i}),'DEGAS') % Determine if parameter isa DEGAS
						for j=1:1:length(obj.(parameterNames{i})) % Loop over DEGAS parameter
                            obj.(parameterNames{i})(j).prepareSim; % Populate base workspace
						end
					end
				end % End i loop
			end

			function onSimulationStart( obj, simObj )
			% DEGAS.onSimulationStart
			%
			% Notify any contained DEGAS objects that the simulation is
			% about to begin.  Can be overriden by derived classes to perform
			% actions prior to simulation.  This is called before
			% prepareSim so that onSimulationStart can determine the value
			% of tunable parameters that are passed to the model in
			% prepareSim.
			%

				parameterNames = fieldnames(obj); % Get all parameter names
				for i=1:1:length(parameterNames) % Loop over all parameters
					if isa(obj.(parameterNames{i}),'DEGAS') % Determine if parameter isa DEGAS
						for j=1:1:length(obj.(parameterNames{i})) % Loop over Block parameter
							obj.(parameterNames{i})(j).onSimulationStart( simObj );
						end % End j loop
					end % End isa if
				end

			end         

			function onSimulationComplete( obj, simObj )
			% DEGAS.onSimulationComplete
			%
			% Notify any contained DEGAS objects that the simulation is
			% complete.  Can be overriden by derived classes to perform
			% actions once simulation is complete.
			%

				parameterNames = fieldnames(obj); % Get all parameter names
				for i=1:1:length(parameterNames) % Loop over all parameters
					if isa(obj.(parameterNames{i}),'DEGAS') % Determine if parameter isa DEGAS
						for j=1:1:length(obj.(parameterNames{i})) % Loop over Block parameter
							obj.(parameterNames{i})(j).onSimulationComplete( simObj );
						end % End j loop
					end % End isa if
                end
            end			
        end    
end