classdef (Sealed = true) NominalEncounterClass < Simulation
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
    properties              
        
        % Event file names
        eventFileNames = {'event1'; 'event2'};        
        
        % Nominal Events
        ac1NominalEvents @ EncounterModelEvents % Aircraft 1
        ac2NominalEvents @ EncounterModelEvents % Aircraft 2

        % Aircraft Dynamics
        ac1Dynamics @ BasicAircraftDynamics % Aircraft 1
        ac2Dynamics @ BasicAircraftDynamics % Aircraft 2
        
        % Control flow of Simulation
        stopConditions @ StopConditions     
        
        % Sensor models
        ac1OwnSense @ PerfectSurveillance % Sensor on ownship to discern own states
        ac1IntSense @ PerfectSurveillance % Sensor on ownship to track intruder    

        % Well clear metrics calculation
        wellClearParameters @ WellClearMetrics     
        
        % Pre and Post processing properties
        encounterFile = ''
        metadataFile = ''
        encounterNumber
        
    end
    
    methods
       function this = NominalEncounterClass() % Constructor
            this = this@Simulation('NominalEncounter');
                      
            % Nominal Event properties
            this.ac1NominalEvents = EncounterModelEvents();
            this.ac2NominalEvents = EncounterModelEvents();
            
            % Aircraft Dynamics properties
            this.ac1Dynamics = BasicAircraftDynamics( 'ac1dyn_');
            this.ac2Dynamics = BasicAircraftDynamics( 'ac2dyn_');

            % Control flow properties
            this.stopConditions = StopConditions('', 'stop_range_ft', 5*DEGAS.nm2ft, 'stop_altitude_ft', 5000);                        
            
            % Sensor Models
            this.ac1OwnSense = PerfectSurveillance('ac1OwnPerfSurv_');
            this.ac1IntSense = PerfectSurveillance('ac1IntPerfSurv_');
            
            % Metrics properties
            this.wellClearParameters = WellClearMetrics('wcm_');                        
                
        end                    

        function theSim = setupEncounter( theSim, encNumber, samples)
            % Load the nominal trajectories (initial states and control
            % update scripts) into the simulation
            %
            %    theSim.setupEncounter( encounter )                                   
            
            if ~exist('samples','var')
                encounters = load(theSim.encounterFile);
                encounters = encounters.samples;
            else
                encounters = samples;
            end
            
            enc2Load = encounters(encNumber);
            
            theSim.ac1Dynamics.v_ftps = enc2Load.v_ftps(1);
            theSim.ac2Dynamics.v_ftps = enc2Load.v_ftps(2);
            
            theSim.ac1Dynamics.N_ft = enc2Load.n_ft(1);
            theSim.ac2Dynamics.N_ft = enc2Load.n_ft(2);
            
            theSim.ac1Dynamics.E_ft = enc2Load.e_ft(1);
            theSim.ac2Dynamics.E_ft = enc2Load.e_ft(2);
            
            theSim.ac1Dynamics.h_ft = enc2Load.h_ft(1);
            theSim.ac2Dynamics.h_ft = enc2Load.h_ft(2);            

            theSim.ac1Dynamics.heading_rad = enc2Load.heading_rad(1);
            theSim.ac2Dynamics.heading_rad = enc2Load.heading_rad(2);                        
            
            theSim.ac1Dynamics.pitchAngle_rad = enc2Load.pitch_rad(1);
            theSim.ac2Dynamics.pitchAngle_rad = enc2Load.pitch_rad(2);
            
            theSim.ac1Dynamics.bankAngle_rad = enc2Load.bank_rad(1);
            theSim.ac2Dynamics.bankAngle_rad = enc2Load.bank_rad(2);
            
            theSim.ac1Dynamics.a_ftpss = enc2Load.a_ftpss(1);
            theSim.ac2Dynamics.a_ftpss = enc2Load.a_ftpss(2);            
            
            theSim.ac1NominalEvents.time_s               = enc2Load.updates(1).time_s;
            theSim.ac1NominalEvents.verticalRate_fps     = enc2Load.updates(1).verticalRate_fps;
            theSim.ac1NominalEvents.turnRate_radps       = enc2Load.updates(1).turnRate_radps;
            theSim.ac1NominalEvents.longitudeAccel_ftpss = enc2Load.updates(1).longitudeAccel_ftpss;
            theSim.ac1NominalEvents.event                = enc2Load.updates(1).event;
            
            theSim.ac2NominalEvents.time_s               = enc2Load.updates(2).time_s;
            theSim.ac2NominalEvents.verticalRate_fps     = enc2Load.updates(2).verticalRate_fps;
            theSim.ac2NominalEvents.turnRate_radps       = enc2Load.updates(2).turnRate_radps;
            theSim.ac2NominalEvents.longitudeAccel_ftpss = enc2Load.updates(2).longitudeAccel_ftpss;
            theSim.ac2NominalEvents.event                = enc2Load.updates(2).event;            
            
            theSim.runTime_s = enc2Load.runTime_s;
            
            theSim.encounterNumber = encNumber;
            
        end       
        
        function r = isNominal(obj)
            % isNominal - Returns true if the simulation object only follows nominal events
            % Abstract function declared in BasicSimulation

            r = true;
            
        end        
    end
    methods (Access = protected)
        function eventScripts = getEventMatrices( this )
         % Must return a cell array containing the event matrix for every aircraft
         %
         % The event matrix = [ time_s(:) verticalRate_fps(:) turnRate_radps(:) longitudeAccel_ftpss(:)]
         
            eventScripts(1) = { this.ac1NominalEvents.event };
            eventScripts(2) = { this.ac2NominalEvents.event };
        end          
    end
    
end