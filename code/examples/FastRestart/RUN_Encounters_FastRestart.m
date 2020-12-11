% RUN_ENCOUNTERS_FASTRESTART
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% This script uses the DAAEncounter simulation located in the the
% code/examples/DAAEncounter directory to run 50 encounters using fast
% restart mode. The results from the simulations are collected and used to
% calculate aggregate metrics.
%
% This script is a notional example of a Monte Carlo implementation since 
% only 50 encounters are used for calculating metrics. Typically, hundreds
% of thousands to millions of encounters are simulated to calculate 
% statistically significant results. 
%
% risk ratio is calculated by the following equation:
%
%                P(NMAC with avoidance logic | Encounter)
% risk ratio = --------------------------------------------
%               P(NMAC without avoidance logic | Encounter)
%
% NMAC - Near mid-air collision
%
%                P(LoWC with avoidance logic | Encounter)
% LoWC ratio = --------------------------------------------
%               P(LoWC without avoidance logic | Encounter)
%
% LoWC - Loss of Well Clear
%
% This script sets up all of the parameters for the simulation object and 
% then runs it 100 times, 50 times for the nominal case and 50 times for 
% the mitigated case
% The results from the simulation are taken and then used to calculate
% aggregate metrics. For more information on aggregate metrics, please look
% at the code and README file in the code/metrics_code directory

% Switch to the directory where this script is located
simDir = which('RUN_Encounters_FastRestart.m');
[simDir,~,~] = fileparts(simDir);
cd(simDir);

% Number of encounters to run
numEncs = 50;

% Encounter file
encFile = [getenv('DEGAS_HOME') filesep 'block_libraries' filesep ...
           'basic_libraries' filesep 'unitTestUtilities' filesep ...
           'Encounters' filesep 'unitTestEncounters.mat'];

% Metadata file
metaFile = [getenv('DEGAS_HOME') filesep 'block_libraries' filesep ...
            'basic_libraries' filesep 'unitTestUtilities' filesep ... 
            'Encounters' filesep 'metaData.mat'];

% Instantiate the simulation object
s = DAAEncounterClass;

% Set the DAIDALUS parameters to the SC-228 Well-Clear Definition
s.daaLogic.setDaidalusToNoncoop;

% Set the Well Clear Boundary to the SC-228 Well-Clear Definition
s.wellClearMetricsParams.setWellClearToNoncoop;

% Set the Pilot Model to follow the guidance bands directly
s.uasPilot.noBufferMode = 1;

% Make sure pilot makes minimum repeatable maneuvers
s.uasPilot.deterministicMode = 1;

% Turn fast restart on
s.fastRestartMode = true;

% Setup the file to read the encounters from
s.encounterFile = encFile;

s.metadataFile = metaFile;

% Load the encounters
encounters = load(s.encounterFile);
encounters = encounters.samples;

% Setup the results for the nominal and mitigated configurations
results_nom = EncounterResults;
results_mit = EncounterResults;

% Loop over all encounters
for ii = 1:1:numEncs
    % For every encounter, run it nominal then mitigated
    for jj = 1:2
        disp(['Simulating encounter number ' num2str(ii)]);
        if jj == 1
            disp('Nominal case');
            % Turn off pilot model
            s.uasPilot.operatorEnabled = 0;
        else
            disp('Mitigated case');
            % Turn on pilot model
            s.uasPilot.operatorEnabled = 1;
        end

        % Setup the encounter
        s.setupEncounter(ii, encounters);  

        tic; 
        evalc('s.runSimulinkFast(ii);'); 
        toc;

        if jj == 1 % Store nominal results
            results_nom = results_nom.storeResults(ii, s.outcome);

            [dataOne, fields_nom] = results_nom.convertToArray;
        else  % Store mitigated results
            results_mit = results_mit.storeResults(ii, s.outcome);

            [dataOne, fields_mit] = results_mit.convertToArray;            
        end
        if ii == 1
            if jj == 1
                data_nom = zeros(length(dataOne),numEncs);
            else
                data_mit = zeros(length(dataOne),numEncs);
            end
        end
        if jj == 1 % Concatenate nominal results
            data_nom(:,ii) = dataOne;
        else % Concatenate mitigated results
            data_mit(:,ii) = dataOne;
        end
    end
end % encounters

% Turn off fast restart mode
s.fastRestartMode = false;

%% Calculating metrics
% For more information on the functions used in this section, read
% code/metrics_code/RUN_metrics_code.m

% Determine which row of the data array holds nmac information
nmac_row_nom = find(strcmp(fields_nom, 'nmac'));
nmac_row_mit = find(strcmp(fields_mit, 'nmac'));

% Extract nmac information
nmacs_nom = logical(data_nom(nmac_row_nom,:));
nmacs_mit = logical(data_mit(nmac_row_mit,:));

% Calculate unweighted risk ratio
[risk_ratio, risk_ratio_ci] = ...
calcRiskRatio(nmacs_mit, nmacs_nom);
% If the user wanted to calculate weighted risk ratio, they would have to
% execute the following command: 
% calcRiskRatio(nmacs_mit, nmacs_nom, 'weights', weight_vec)
% where weight_vec is the vector of weights equal in length to the
% nmacs_mit and nmac_nom vector


% Determine which row of the data array holds lowc information
lowc_row_nom = find(strcmp(fields_nom, 'lowc'));
lowc_row_mit = find(strcmp(fields_mit, 'lowc'));

% Extract lowc information
lowc_nom = logical(data_nom(lowc_row_nom,:));
lowc_mit = logical(data_mit(lowc_row_mit,:));

% Calculate unweighted loss of well clear ratio
[lowc_ratio, lowc_ratio_ci] = ...
calcLowcRatio(lowc_mit, lowc_nom)
% If the user wanted to calculate weighted LoWC ratio, they would have to
% execute the following command: 
% calcLowcRatio(lowc_mit, lowc_nom, 'weights', weight_vec)
% where weight_vec is the vector of weights equal in length to the
% lowc_mit and lowc_nom vector