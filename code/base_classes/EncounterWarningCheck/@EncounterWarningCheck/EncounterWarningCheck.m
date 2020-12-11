classdef EncounterWarningCheck < handle
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% EncounterWarningCheck: Contains functions that check simulated 
% encounters for common errors - i.e. if the ownship alerted within the 
% first 5 seconds of the encounter, if the ownship or intruder altitude 
% went negative, etc.

    properties
        warningFlag logical = false  % Was there a warning flag raised?
        warningMessages cell = {}    % What are the associated messages?
        encounterNumber {mustBeInteger} % Which encounter was last run
        hmdTol {mustBePositive} = 1 % Tolerance for hmd check (ft)
        vmdTol {mustBePositive} = 1 % Tolerance for vmd check (ft)
        skipCheck logical = false; % Skip checking encounter for warnings
    end
    
    methods
        function obj = EncounterWarningCheck() % constructor
        end
        function checkEncounter(this,simObj)
        % checkEncounter: Runs all of the functions which check various
        % fields of the end-to-end simulation function after it runs
        
            if ~this.skipCheck
        
                % Clear warnings from previous run
                this.warningMessages = {};

                % Set encounter number
                this.encounterNumber = [simObj.encounterNumber];

                % Perform checks
                this.checkOwnAndIntAlt(simObj);
                this.checkOwnshipAlerts(simObj);
                this.checkCPATime(simObj);
                this.checkNomHmdAndVmd(simObj);

                % Print out warning messages
                this.printWarningMessages();
            end
        end   
        
        function appendWarningMessage(this, message)
        % appendWarningMessage: Adds an additional warning message to the 
        % warningMessage property of the encounterWarningCheck class
            this.warningMessages{end+1} = message;
        end  
        
        function printWarningMessages(this)
        % printWarningMessages: Prints all of the warning messages in the
        % warningMessages cell of the object
        
            if(~isempty(this.warningMessages))
                warning('off','backtrace');
                disp(newline);   
                warningPrefix = ['FOR ENCOUNTER ' num2str(this.encounterNumber(end)) ': *** '];
                for ii = 1:length(this.warningMessages)                
                    warning(strcat(warningPrefix, this.warningMessages{ii},' ***'));
                end
                disp(newline);
                warning('on','backtrace');
            end  
            
        end
        
        function checkOwnAndIntAlt(this, simObj)
        % checkOwnAndIntAlt: Checks if the ownship or intruder altitude is
        % below 0 ft. at any point in the simulation.
        % If so, a warning is added to the warningMessages field and
        % warningFlag is set to true.
        
            own_alt = simObj.results(1).up_ft;
            int_alt = simObj.results(2).up_ft;

            if any(own_alt < 0)
                this.warningFlag = true;
                message = 'Ownship altitude goes below 0 ft. in simulation.';
                this.appendWarningMessage(message);
            end
            if any(int_alt < 0)
                this.warningFlag = true;
                message = 'Intruder altitude goes below 0 ft. in simulation.';
                this.appendWarningMessage(message);
            end            
        end
        
        function checkOwnshipAlerts(this, simObj)
        % checkOwnshipAlerts: Checks to see if the ownship alerted during
        % the first 5 seconds of the encounter.s
        % If so, a warning is added to the warningMessages field and
        % warningFlag is set to true.        
        
            if ~simObj.isNominal
        
                all_alerts = simObj.getSimulationOutput('AvoidFlag');
                own_alerts = all_alerts(:,1);

                simTime = simObj.results(1).time;
                idx_before5Seconds = simTime <= 5;

                if any(own_alerts(idx_before5Seconds))
                    this.warningFlag = true;
                    message = 'Ownship alerts within 5 seconds of the start of the simulation.';
                    this.appendWarningMessage(message);
                end
            
            end
        end
        
        function checkCPATime(this, simObj)
        % checkCPATime: Checks if the CPA time happens at the last timestep.
        % If so, a warning is added to the warningMessages field and
        % warningFlag is set to true.
        
            tca = simObj.outcome.tca;
            tout = simObj.readFromWorkspace('tout');
            
            if (tout(end) == tca)
                this.warningFlag = true;
                message = 'CPA occurs at the last timestep of the simulation.';
                this.appendWarningMessage(message);                
            end
            
        end
        
        function checkNomHmdAndVmd(this, simObj)
        % checkNomHmdAndVmd: Checks if the nominal hmd and vmd from the
        % simulated encounter match the nominal hmd and vmd in the metadata
        % file

            if ~isempty(simObj.metadataFile) && simObj.isNominal
                
                metaData = load(simObj.metadataFile);
                metaData = metaData.enc_metadata;                
                
                sim_hmd = simObj.readFromWorkspace('hmd_mhd_ft');
                sim_vmd = simObj.readFromWorkspace('vmd_mhd_ft');
                
                metadata_hmd = metaData(simObj.encounterNumber).hmd;
                metadata_vmd = metaData(simObj.encounterNumber).vmd;                

                % Check if the simulated nominal HMD and VMD are within
                % tolerance the metadata HMD and VMD
                hmdCheck = ismembertol(sim_hmd, metadata_hmd, this.hmdTol, 'DataScale', 1);
                vmdCheck = ismembertol(sim_vmd, metadata_vmd, this.vmdTol, 'DataScale', 1);

                if ~hmdCheck
                    this.warningFlag = true;
                    message = ['Nominal HMD from simulation does not match '...
                               'nominal HMD in metadata file. Simulated '...
                               'HMD: ', num2str(sim_hmd),...
                               ' , metadata HMD: ', ...
                               num2str(metadata_hmd)];
                    this.appendWarningMessage(message);                       
                end
                if ~vmdCheck
                    this.warningFlag = true;
                    message = ['Nominal VMD from simulation does not match '...
                               'nominal VMD in metadata file. Simulated '...
                               'VMD: ', num2str(sim_vmd),...
                               ' , metadata VMD: ', ...
                               num2str(metadata_vmd)];
                    this.appendWarningMessage(message);                       
                end
                
            end
        
        end
        
    end    
end