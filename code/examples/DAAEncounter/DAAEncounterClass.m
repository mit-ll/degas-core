classdef DAAEncounterClass < Simulation
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% DAAENCOUNTERCLASS Example Simulink model of a mitigated two aircraft encounter 

    properties
        
        % Event file names
        eventFileNames = {'event1'; 'event2'};
        
        % Simulation specific parameters. These parameters do not have a
        % specific 
        sim_sampleTime             = 0.1; % The simulation sample time, normally 10 Hz
        ignorePrevAlert            = 1; % Ignore preventive alerts; 1 - on, 0 - off
        enableVertMan              = 0; % Vertical maneuvers are disabled by default
        enableHorzMan              = 1; % Allow horizontal maneuvers     
        uasLogic_sampleTime        = 1.0; % The logic will process at 1 Hz
        uasSurveillance_sampleTime = 0.1; % The surveillance will process at 10 Hz
        
        % Simulation specific variables need to be put into the base
        % workspace. Normally a DEGAS derived class will put all of the
        % tunable parameters into the base workspace via the method
        % prepareSim in the DEGAS class. These parameters can be put into
        % the base workspace by appending them into the complete list of
        % tunable parameters        
        simSpecificVars = {'ignorePrevAlert', 'enableVertMan', 'enableHorzMan',...
                           'uasLogic_sampleTime','uasSurveillance_sampleTime',...
                           'sim_sampleTime', 'eventFileNames'};        
        
        % Nominal Events
        ac1NominalEvents @ EncounterModelEvents % Aircraft 1
        ac2NominalEvents @ EncounterModelEvents % Aircraft 2

        % Aircraft Dynamics
        ac1Dynamics @ BasicAircraftDynamics % Aircraft 1
        ac2Dynamics @ BasicAircraftDynamics % Aircraft 2
        
        % Control flow of Simulation
        stopConditions @ StopConditions       
        
        % Pilot model
        uasPilot @ HeuristicOperatorModelR6
        
        % DAA System model
        daaLogic @ DaidalusV201
        
        % Additional blocks that process the alert signal coming out of
        % DAIDALUS
        MofN @ MofNFilter
        Hyst @ HysteresisFilter

        % Well clear metrics calculation
        wellClearMetricsParams @ WellClearMetrics                         
        
        % Sensor models
        ac1OwnSense @ PerfectSurveillance % Sensor on ownship to discern own states
        ac1IntSense @ PerfectSurveillance % Sensor on ownship to track intruder 
        
        % Transponder models, used to calculate pNMAC
        ac1Transponder @ Transponder
        ac2Transponder @ Transponder
        
        % Pre and Post processing properties
        encounterFile = ''
        metadataFile = ''
        encounterNumber
        
    end
    methods        
        function this = DAAEncounterClass() % Constructor
            this = this@Simulation('DAAEncounter');
                      
            % Nominal Event properties
            this.ac1NominalEvents = EncounterModelEvents();
            this.ac2NominalEvents = EncounterModelEvents();
            
            % Aircraft Dynamics properties
            this.ac1Dynamics = BasicAircraftDynamics( 'ac1dyn_');
            this.ac2Dynamics = BasicAircraftDynamics( 'ac2dyn_');

            % Control flow properties
            this.stopConditions = StopConditions('', 'stop_range_ft', 5*DEGAS.nm2ft, 'stop_altitude_ft', 5000);
                        
            % Pilot model properties
            this.uasPilot = HeuristicOperatorModelR6('uasPilot_');
            avoid_maneuver_bus_definition();

            % DAIDALUS Properties
            this.daaLogic = DaidalusV201('daa_');
            
            % Additional DAIDALUS Alert processing blocks
            this.MofN = MofNFilter('ac1AlertMofN_');
            this.Hyst = HysteresisFilter('ac1AlertHyst_');
            
            % Sensor Models
            this.ac1OwnSense = PerfectSurveillance('ac1OwnPerfSurv_', 'surveillanceSampletime_s', this.uasSurveillance_sampleTime );
            this.ac1IntSense = PerfectSurveillance('ac1IntPerfSurv_', 'surveillanceSampletime_s', this.uasSurveillance_sampleTime );            
            
            % Setting up the transponders used to calculate pNMAC
            this.ac1Transponder = Transponder('trans1_');
            this.ac2Transponder = Transponder('trans2_');
            
            % Metrics properties
            this.wellClearMetricsParams = WellClearMetrics('wcm_');                        
                
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
        
        function r = isNominal (obj)
            % Should return true when the simulation is configured to simulate the "nominal" (unequipped) trajectories
            if obj.uasPilot.operatorEnabled == 0
              r = true;
            else
              r = false;
            end
        end          
        % Override
        function onSimulationComplete( this, simObj )
                                    
            onSimulationComplete@Simulation( this, simObj );
            this.results(1).Advisory = this.getSimulationOutput( 'UAS Advisory' );
            busReader = AircraftCommandsBusReader( this.results(1).Advisory );
            this.results(1).advisedClimbRate_ftps = busReader.dh_ftps;
            this.results(1).advisedClimbRate_ftps( ~busReader.dh_flag ) = nan;

            % record alerts
            this.getAlertData;

            % record maneuvers
            maneuverFlag = this.getSimulationOutput('ManeuverFlag');
            if any(maneuverFlag)
              this.outcome.tManeuver = this.results(1).time(find(maneuverFlag,1));
            else
              this.outcome.tManeuver = NaN;
            end

            % well clear metrics
            this.computeWellClearMetrics;                

            % nominal trajectory states (assumes no intruder avoidance maneuvering)
            aircraftStates = this.getSimulationOutput('OwnNominalState');
            aircraftStateRates = this.getSimulationOutput('OwnNominalStateRt');
            assert( mod( size( aircraftStates, 2 ), AircraftStateBusReader.width ) == 0 );
            assert( mod( size( aircraftStateRates, 2 ), AircraftStateRateBusReader.width ) == 0 );

            this.results_nominal = this.results;
            storeAircraftStates(this, 'results_nominal', aircraftStates, aircraftStateRates, 1);
            
            
        end  % end onSimulationComplete

        function plot(obj)
          
            plot@Simulation(obj);
            
            % use larger vertical rate limits
            h = gca;
            set(h,'Ylim',[-3000 3000]);
            
            if strcmp(obj.plottype, 'none')
            
                % add well clear status to title
                h = get(gcf, 'Children');
                h = h(6);
                h = get(h, 'Title');
                titleStr = get(h, 'String');
                titleStr{1} = [titleStr{1},  ', WCV = ' num2str(~isnan(obj.outcome.tLossofWellClear)) ];
                set(h, 'String', titleStr);                
                
            end
        end % End plot function            
    
    end
    
        methods(Access=protected)
        
        function eventScripts = getEventMatrices( this )
         % Must return a cell array containing the event matrix for every aircraft
         %
         % The event matrix = [ time_s(:) verticalRate_fps(:) turnRate_radps(:) longitudeAccel_ftpss(:)]
         
            eventScripts(1) = { this.ac1NominalEvents.event };
            eventScripts(2) = { this.ac2NominalEvents.event };
        end      
        
        % Select which properties are exposes as simulation parameters
        function [varName, varValue] = getTunableParameters( obj, varName )
                                 
            if( nargin < 2 )
              varName = {};
            end
            
            varName = cat( 2, varName, obj.simSpecificVars);            
            [ varName, varValue ] = obj.getTunableParameters@Simulation( varName );
            
        end
        
    end
    
    methods   % helper functions
      
        function obj = storeAircraftStates(obj, structName, aircraftStates, aircraftStateRates, numAircraft)
          
            for aidx = 1 : numAircraft
                acState = AircraftStateBusReader( aircraftStates(:,(aidx-1)*AircraftStateBusReader.width+(1:AircraftStateBusReader.width)) );
                obj.(structName)(aidx).north_ft = acState.n_ft;
                obj.(structName)(aidx).east_ft = acState.e_ft;
                obj.(structName)(aidx).up_ft = acState.h_ft;
                obj.(structName)(aidx).speed_ftps = acState.v_ftps;
                obj.(structName)(aidx).psi_rad = acState.psi_rad;
                obj.(structName)(aidx).theta_rad = acState.theta_rad;
                obj.(structName)(aidx).phi_rad = acState.phi_rad;
                obj.(structName)(aidx).vertical_speed_ftps = acState.dh_ftps;
                obj.(structName)(aidx).hdd_ftps2 = acState.ddh_ftps2;
                obj.(structName)(aidx).latitude_rad = acState.latLonAltState.lat_rad;
                obj.(structName)(aidx).longitude_rad = acState.latLonAltState.lon_rad;
                obj.(structName)(aidx).altitude_ft = acState.latLonAltState.alt_ft;
                obj.(structName)(aidx).dLatitude_radps = acState.latLonAltState.dlat_radps;
                obj.(structName)(aidx).dLongitude_radps = acState.latLonAltState.dlon_radps;
                obj.(structName)(aidx).dAltitude_ftps = acState.latLonAltState.dalt_ftps;

                acStateRate= AircraftStateRateBusReader( aircraftStateRates(:,(aidx-1)*AircraftStateRateBusReader.width+(1:AircraftStateRateBusReader.width)) );
                varNames = fields( acStateRate );
                for k = 1 : numel(varNames)
                    obj.(structName)(aidx).(varNames{k}) = acStateRate.(varNames{k});
                end
            end
        end
        
        function obj = computeWellClearMetrics(obj)
            % Processes the well clear information collected from the
            % simulation
            % tLossofWellClear - Time of Loss of Well Clear in the
            % simulation
            % dtLowc - Length of Loss of Well Clear 
            
            wcvTrace = obj.getSimulationOutput('WCMetrics');

            tWcv = nan(1,1);
            dtWcv = zeros(1,1);
            
            i = 1;
            idx = find(wcvTrace(:,i));
            if ~isempty(idx)
              tWcv(i) = obj.results(1).time(idx(1));
              dtWcv(i) = obj.results(1).time(idx(end)) - obj.results(1).time(idx(1));
            end
            obj.outcome.tLossofWellClear = tWcv;
            obj.outcome.dtLowc = dtWcv;
            
        end % method
        
        function obj = getAlertData(obj)
        % Populate the outcome field with Alert data
            avoidFlag = obj.getSimulationOutput('AvoidFlag');
            maneuverFlag = obj.getSimulationOutput('ManeuverFlag');
              
            obj.outcome.alert = any(avoidFlag);
            obj.outcome.maneuverFlag = any(maneuverFlag);

            % own alerts
            if any(maneuverFlag)
              manIdx = find(maneuverFlag,1);
            else
              manIdx = length(maneuverFlag);
            end
            df = diff(avoidFlag(1:manIdx,1));

            obj.outcome.numAlerts = sum(df > 0);
            
            if obj.outcome.alert(1)
              tIdx = find(df>0,1,'first') + 1;
              obj.outcome.tFirstAlert = obj.results(1).time(tIdx);
              tIdx = find(df>0,1,'last') + 1;
              obj.outcome.tLastAlert = obj.results(1).time(tIdx);
            else
              obj.outcome.tFirstAlert = NaN;
              obj.outcome.tLastAlert = NaN;
            end
          
        end % method
      
    end
end