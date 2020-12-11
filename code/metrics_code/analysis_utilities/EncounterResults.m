classdef EncounterResults
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% EncounterResults: Holds results of interest from a simulation

    properties
        encId % Encounter ID
        systemTime_s % Time it took for simulation to run on the system
        alert % Did the ownship alert
        lowc % Was there a loss of well clear?
        nmac % Was there an NMAC?
        tca % Time of closest approach in seconds
        hmd_ft % Horizontal Missed Distance
        vmd_ft % Vertical Missed Distance
        tOwnAlert % Time the ownship alerted
        tFirstManeuver % Time of the first maneuver
        tLowc % Time of the loss of well clear
        dtLowc % Duration of loss of well clear
    end
    
    methods
        
        function this = storeResults(this, encounterNumber, outcome)
            % Extracts data from 'outcome' and stores in the object's properties
            
            this.encId = encounterNumber;
            
            if isfield(outcome,'nmac')
                this.nmac = outcome.nmac;
            end
            
            if isfield(outcome,'systemTime_s')
                this.systemTime_s = outcome.systemTime_s;
            end
            
            if isfield(outcome,'tLossofWellClear')
                this.lowc = ~isnan(outcome.tLossofWellClear) && outcome.dtLowc >= 1;
            end
            
            if isfield(outcome,'alert')
                this.alert = outcome.alert(1);
            end
            
            if isfield(outcome,'hmd_ft')
                this.hmd_ft = outcome.hmd_ft;
            end
            
            if isfield(outcome,'vmd_ft')
                this.vmd_ft = outcome.vmd_ft;
            end
            
            if isfield(outcome,'tca')
                this.tca = outcome.tca;
            end
            
            if isfield(outcome,'tFirstAlert')
                this.tOwnAlert = outcome.tFirstAlert;
            end
            
            if isfield(outcome, 'tLossofWellClear')
                this.tLowc = outcome.tLossofWellClear;
            end
            
            if isfield(outcome, 'dtLowc')
                this.dtLowc = outcome.dtLowc;
            end
            
            if isfield(outcome, 'tManeuver')
                this.tFirstManeuver = outcome.tManeuver;
            end
            
        end
        
        function this = addResult(this,field, value)
            
            this.(field) = value;
            
        end
        
        function [data, elNames] = convertToArray(this)
            % Returns column vector of the object's contents and the corresponding
            % element names.  Empty fields are returned as NaN;
            
            fields = fieldnames(this);
            numFields = length(fields);
            elSize = zeros(numFields,1);
            for i=1:numFields
                elSize(i) = max(1,numel(this.(fields{i})));  % set to one if field is empty
            end
            totalSize = sum(elSize);
            
            data = zeros(totalSize,1);
            elNames = cell(totalSize,1);
            last = 0;
            for i=1:numFields
                for j=last+1:sum(elSize(1:i))
                    if ~isempty(this.(fields{i}))
                        data(j) = this.(fields{i})(j-last);
                    else
                        data(j) = NaN;
                    end
                    elNames{j} = fields{i};
                end
                last = j;
            end
            
        end
        
    end
    
end %classdef