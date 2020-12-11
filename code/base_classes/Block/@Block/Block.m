classdef Block < DEGAS
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% Block: The main class that almost every wrapper class in 
% `/DEGAS/code/block_libraries/` derives from. If the user creates a 
% custom Simulink block and wants to use it in their end-to-end simulation,
% the associated Simulink block class must be derived from Block.
% 
    %%
    properties (GetAccess = 'public', SetAccess = 'public')
        tunableParameterPrefix; % optional prefix appended to the names of
        % all model parameters corresponding to this block
    end % end properties
    
    %%
    methods(Access=protected)
        
        function [varName, varValue] = getTunableParameters( obj, varName )
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
            % that omits properties of the object that should not be
            % treated as Simulink model parameters
            
            if( nargin < 2 )
                varName = setdiff( properties(obj), { 'tunableParameterPrefix', 'type' });
            end
            varValue = varName;
            for i = 1:numel(varName)
                % Simulink doesn't allow enumerated values to be pulled
                % into models, so convert enumerated types into their
                % numeric equivalent
                curVal = obj.(varName{i});
                if( ~isempty( enumeration( curVal ) ) )
                    % Its enumerated.  Convert to numeric
                    varValue{i} = double( curVal );
                else
                    % Not enumerated.  No conversion required
                    varValue{i} = curVal;
                end
                varName{i} = [obj.tunableParameterPrefix, varName{i}];
            end
        end
        
    end    
    methods(Sealed,Access=private)
        
        function setDegasTunableParameters( obj )
            % Put model parameters where Simulink model can find them
            %
            %  block.setDegasTunableParameters()
            %
            %  Create variables for model parameters in the base workspace
            %
            %
            %Tunable parameter names are block.tunableParameterPrefix
            %appended to the property name as declared in the MATLAB
            %class definition.  The tunableParameterPrefix allows one to
            %disambiguate between the parameters of multiple blocks of the
            %same type in your model.
            %
            %For example, the library block Basic Aircraft Dynamics is
            %associated with the class BasicAircraftDynamics, which is derived from
            %Block.  The Simulink model nominalEncounter contains two Basic
            %Aircraft Dynamics blocks.  In the first, all of the mask
            %parameters have been set to strings starting with "ac1dyn_";
            %For instance "ac1dyn_v_ftps", "ac1dyn_N_ft" and so on.  In the
            %second all of the mask parameters start with "ac2dyn_";
            %For instance "ac2dyn_v_ftps", "ac2dyn_N_ft" and so on.  In the
            %class BasicAircraftDynamics there are properties named "v_ftps" and
            %"N_ft".  So if we create one BasicAircraftDynamics object using the
            %tunable parameter prefix "ac1dyn_" (the constructor of
            %BasicAircraftDynamics sets Block.tunableParameterPrefix to the first
            %parameter it is passed):
            %
            %   aircraft1 = BasicAircraftDynamics( 'ac1dyn_' );
            %
            % and create a second Simple6DOF object using the tunable
            % parameter prefix "ac2dyn_":
            %
            %   aircraft2 = BasicAircraftDynamics( 'ac2dyn_' );
            %
            % then we can set the parameter values of these two block
            % independently, and when Block.setDegasTunableParameters is
            % called it will affect the appropriate blocks in the
            % simulation:
            %
            %   aircraft1.v_ftps = 11;
            %   aircraft1.N_ft   = 101;
            %   aircraft2.v_ftps = -12;
            %   aircraft2.N_ft   = -112;
            %   aircraft1.setDegasTunableParameters();
            %   aircraft2.setDegasTunableParameters();
            %
            % We can see that separated variables have been created in the
            % base workspace for each of the two dynamics blocks:
            %
            %         >> ac1dyn_N_ft
            %
            %         ac1dyn_N_ft =
            %
            %            101
            %
            %         >> ac2dyn_N_ft
            %
            %         ac2dyn_N_ft =
            %
            %           -112
            %
            
            errBlock = [];
            try
                isNoBlockWarnings = evalin('base','isNoBlockWarnings');
            catch errBlock
                isNoBlockWarnings = false;
            end
            
            assert(isa(obj,'Block'));
            
            classMethods = methods(obj);
            if any(strcmp(classMethods,'prepareProperties'));
                obj.prepareProperties;
            end
            
            for ii=1:1:length(obj)
                [varName, varValue] = obj(ii).getTunableParameters;
                for i = 1:numel(varName)
                    assignin('base',varName{i},varValue{i})
                end
            end
        end
        
    end    
    methods(Sealed)        
        % Override DEGAS.prepareSim to call Block.setDegasTunableParameters
        function prepareSim(obj)
        % Loop over DEGAS objects to populate the base workspace with
        % tunable parameters
            % save variables to workspace (Simulink)            
            for j=1:1:length(obj) % Loop over Block parameter
                obj(j).setDegasTunableParameters; % Populate base workspace
            end % End j loop
            
            % Call base class to get any child objects under this Block
            obj.prepareSim@DEGAS();
        end        
    end % End methods
end % End classdef