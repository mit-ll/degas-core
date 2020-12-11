classdef EncounterModelEvents < handle
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% EncounterModelEvents: The EncounterModelEvents class contains properties 
% that dictate which events happen at what time in the simulation. This 
% class is also used to populate the current directory with 'event' .mat 
% files used by the end-to-end simulation. EncounterModelEvents is 
% expected to be added to the end-to-end simulation as a property so that 
% the directory where the end-to-end simulation is being run can be 
% populated with 'event' .mat files.
%
% The EncounterModelEvents class contains properties that dictate which
% events happen at what time in the simulation. This class is also used to
% populate the base workspace with 'event' .mat files using the method
% createEventMatrix

    properties (GetAccess = 'public', SetAccess = 'public')
        time_s = 0; % seconds
        verticalRate_fps = 0; % Vertical rate of the aircraft in feet per second
        turnRate_radps = 0; % Turn rate of the aircraft in radians per second
        longitudeAccel_ftpss = 0; % Acceleration feet per second squared
    end % end properties
    
    properties (Dependent=true)
        event % The event matrix = [ time_s(:) verticalRate_fps(:) turnRate_radps(:) longitudeAccel_ftpss(:)]
    end
    methods
        function this = set.event( this, eventMatrix )
            assert( size( eventMatrix,2 ) == 4 );
            this.time_s = eventMatrix(:,1);
            this.verticalRate_fps = eventMatrix(:,2);
            this.turnRate_radps = eventMatrix(:,3);
            this.longitudeAccel_ftpss = eventMatrix(:,4);
        end
        function eventMatrix = get.event( this )            
            eventMatrix = [this.time_s(:) this.verticalRate_fps(:) this.turnRate_radps(:) this.longitudeAccel_ftpss(:)];
            % eventMatrix always needs to have at least one row, or
            % Simulink FromFile blocks will produce errors 
            % (at least they do in RSIM executables)
            if( size( eventMatrix, 1 ) == 0 )
                eventMatrix = [ 0 0 0 0 ];
            end
        end
    end
    
    %%
    methods(Access = 'public')
        function obj = EncounterModelEvents (varargin)  
            % Parse Inputs
            p = inputParser;
            if any(strcmp(varargin,'event'))
                addParameter(p,'event',[0 0 0 0],@isnumeric);
            else % If event matrix is being passed, ignore control individual properties
                addParameter(p,'time_s',obj.time_s,@isnumeric);
                addParameter(p,'verticalRate_fps',obj.verticalRate_fps,@isnumeric);
                addParameter(p,'turnRate_radps',obj.turnRate_radps,@isnumeric);
                addParameter(p,'longitudeAccel_ftpss',obj.longitudeAccel_ftpss,@isnumeric);
            end   
            parse(p,varargin{:});
            
            % Set Properties
            fieldsSet = intersect( fieldnames(p.Results), fieldnames(obj) );  
            for i = 1:1:numel(fieldsSet)
                obj.(fieldsSet{i}) = p.Results.(fieldsSet{i});
            end
            
            % Error Checking
            assert(all((size(obj.time_s) == size(obj.verticalRate_fps)) == (size(obj.turnRate_radps) == size(obj.longitudeAccel_ftpss))),'Sizes of time_s, verticalRate_fps, turnRate_radps, longitudeAccel_ftpss are not equal');
        end % End constructor
        
        function event = createEventMatrix(obj,filename)
            assert(ischar(filename),'Second input must be a char'); % Error checking
            event = obj.event';% Format according to how Logic and Response: Nominal Trajectory block is expecting
            save(filename, 'event'); % Save .mat file for block
        end        
        
    end % End methods    
end %End classdef