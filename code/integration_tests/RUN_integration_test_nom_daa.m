% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% RUN_integration_test - Run tests on the example simulations to ensure
% that DEGAS is working as intended.
%
% This script runs the Nominal Encounter and and DAA Encounter simulations  
% located in /DEGAS/code/examples/ and compares the results with
% precalculated trajectories. If there are discrepencies between the results 
% of the example simulations and the precalculated trajectories, a warning
% will be output to the Command Window. The integration test assumes that 
% the Nominal Encounter, DAA Encounter Simulink models, and the blocks 
% that they contain have not been structurally modified in any way from the
% versions in the repository. 
%
% The truth results are located in ./savedResults/nom_daa_test_results
%
% sim_results_nom.mat contains selected precomputed time histories for
% the Nominal Encounter Simulation
% sim_results_mit_perf.mat contains selected precomputed time histories for
% the DAA Encounter Simulation given that both the ownship and intruder
% sensor are using the Perfect Surveillance block 

%% Pre-processing

simDir = which('RUN_integration_test_nom_daa.m');
[simDir,~,~] = fileparts(simDir);
cd(simDir);

clc

%% Run Nominal Encounter

disp([newline 'Running integration test on NominalEncounterClass and NominalEncounter.slx...' newline])

% All of the setup steps below are from
% /DEGAS/code/examples/NominalEncounter/RUN_NominalEncounter.m

% Clear the simulation object
clear s_nom

% Instantiate the simulation object
s_nom = NominalEncounterClass;

% Setup the file to read the encounters from
s_nom.encounterFile = 'integrationTestEncounter.mat';

% Setup the encounter.
s_nom.setupEncounter(1);

% Run the simulation
evalc('s_nom.runSimulink(1)');

%% Compare Nominal Encounter results

passFlagNom = false;

clear truth

% Load nominal truth data
truth = load('sim_results_nom.mat');

% Set the system runtime to 0 because this will always be different for
% every run
truth.outcome.systemTime_s = 0;

% s_nom.outcome field cannot be manipulated directly so copying
outcome = s_nom.outcome;
outcome.systemTime_s = 0;

% Check if the outcome structures are equivalent
outcomeFieldsFailed_nom = compareFields('s_nom.outcome',truth.outcome,outcome, 'outcomeFieldsFailed_nom');

% Check if the results structures are equivalent
resultsFieldsFailed_nom = compareFields('s_nom.results',truth.results, s_nom.results, 'resultsFieldsFailed_nom');

% Check if the nominal results structures are equivalent
resultsNomFieldsFailed_nom = compareFields('s_nom.results_nominal',truth.results_nominal, s_nom.results_nominal, 'resultsNomFieldsFailed_nom');

% Check if the Well clear metrics structures are equivalent   
wcmFailed_nom = compareValues('s_nom.getSimulationOutput(''WCMetrics'')',truth.WCMetrics,s_nom.getSimulationOutput('WCMetrics'));    

if (isempty(outcomeFieldsFailed_nom) && isempty(resultsFieldsFailed_nom) && isempty(resultsNomFieldsFailed_nom) && ~wcmFailed_nom)
    passFlagNom = true;
    disp([newline 'NominalEncounter.slx passes the integration test.'])
else
    warning([newline 'NominalEncounter.slx does not pass the integration test. Read warnings output above.']);
end

%% Run DAA Encounter

% All of the setup steps below are from
% /DEGAS/code/examples/DAAEncounter/RUN_DAAEncounter.m

disp([newline 'Running integration test on DAAEncounterClass and DAAEncounter.slx...' newline])

% Clear the simulation object
clear s_mit

% Instantiate the simulation object
s_mit = DAAEncounterClass;

% Set the DAIDALUS parameters to the SC-228 Well-Clear Definition
s_mit.daaLogic.setDaidalusToNoncoop;

% Set the Well Clear Boundary to the SC-228 Well-Clear Definition
s_mit.wellClearMetricsParams.setWellClearToNoncoop;

% Set the Pilot Model to follow the guidance bands directly
s_mit.uasPilot.noBufferMode = 1;

% Set the pilot to deterministic mode
s_mit.uasPilot.deterministicMode = 1;

% Setup the file to read the encounters from
s_mit.encounterFile = 'integrationTestEncounter.mat';

% Setup the encounter
s_mit.setupEncounter(1);

% Run the simulation.
evalc('s_mit.runSimulink(1)');

%% Compare DAA Encounter results

passFlagMit = false;

clear truth

% Load DAAEncounter perfect truth data
truth = load('sim_results_mit_perf.mat');

% Set the system runtime to 0 because this will always be different for
% every run
truth.outcome.systemTime_s = 0;

% s_nom.outcome field cannot be manipulated directly so copying
outcome = s_mit.outcome;
outcome.systemTime_s = 0;

% Check if the outcome structures are equivalent
outcomeFieldsFailed_mit = compareFields('s_mit.outcome',truth.outcome,outcome, 'outcomeFieldsFailed_mit');

% Check if the results structures are equivalent
resultsFieldsFailed_mit = compareFields('s_mit.results',truth.results, s_mit.results, 'resultsFieldsFailed_mit');

% Check if the nominal results structures are equivalent
resultsNomFieldsFailed_mit = compareFields('s_mit.results_nominal',truth.results_nominal, s_mit.results_nominal, 'resultsNomFieldsFailed_mit');

% Check if the daaGuidance values are equivalent
daaFailed_mit = compareValues('s_mit.readFromWorkspace(''daaGuidance'')',truth.daaGuidance,s_mit.readFromWorkspace('daaGuidance'));    

% Check if the pilotModel values are equivalent 
pilotFailed_mit = compareValues('s_mit.getSimulationOutput(''UAS Advisory'')',truth.pilotCommands,s_mit.getSimulationOutput('UAS Advisory'));    

% Check if the maneuverFlag values are equivalent
manFlagFailed_mit = compareValues('s_mit.getSimulationOutput(''ManeuverFlag'')',truth.manFlag,s_mit.getSimulationOutput('ManeuverFlag'));    

% Check if the Well clear metrics structures are equivalent   
wcmFailed_mit = compareValues('s_mit.getSimulationOutput(''WCMetrics'')',truth.WCMetrics,s_mit.getSimulationOutput('WCMetrics'));    

if (isempty(outcomeFieldsFailed_mit) && ...
    isempty(resultsFieldsFailed_mit) && ...
    isempty(resultsNomFieldsFailed_mit) && ...
    ~wcmFailed_mit && ...
    ~daaFailed_mit && ...
    ~pilotFailed_mit && ...
    ~manFlagFailed_mit)

    passFlagMit = true;
    disp([newline 'DAAEncounter.slx passes the integration test.'])
else
    warning([newline 'DAAEncounter.slx does not pass the integration test. Read warnings output above.']);
end

%% Final Check

if passFlagMit && passFlagNom
    disp('Both NominalEncounter.slx and DAAEncounter.slx pass the integration test.')
elseif passFlagMit && ~passFlagNom
    disp('DAAEncounter.slx passes integration test.');
    warning(['NominalEncounter.slx does not pass the integration test.'...
        ' Please confirm that NominalEncounter.slx has not been modified and rerun.']);
elseif ~passFlagMit && passFlagNom
    disp('NominalEncounter.slx passes integration test.');
    warning(['DAAEncounter.slx does not pass the integration test.'...
        ' Please confirm that DAAEncounter.slx has not been modified and rerun.']);    
elseif ~passFlagMit && ~passFlagNom
    warning(['Both NominalEncounter.slx and DAAEncounter.slx pass the integration test.',...
             ' Please confirm that they have not been modified and rerun.'])
end

%% Helper functions
function fnamesFail = compareFields(structName,obj1, obj2, outputName)
% Compares the numerical values of the fields from two objects. The objects
% are assumed to have the same fields and be of the same size. Displays 
% what fields have differing values.
% structName - Name of the structure being tested
% obj1 - The truth object
% obj2 - The object to compare
% fnamesFail - fields that failed the numerical comparison
% outputName - Name of the variable that fnamesFail is being assigned to

fnamesFail = {};

fnames = fieldnames(obj1);

count = 0;

sizeObjs = max(size(obj1));

for jj = 1:sizeObjs

    for ii = 1:numel(fnames)

        curr_field = fnames{ii};

        val_true = obj1(jj).(curr_field);
        
        val_test = obj2(jj).(curr_field);
        
        if length(val_true) > 1
           
            val_true = val_true(~isnan(val_true));
            
            val_test = val_test(~isnan(val_test));
            
        end
        
        if isequal(val_true,val_test) || all(isnan(val_true) & isnan(val_test))
            continue;
        else
            count = count + 1;
            if sizeObjs == 1
                fnamesFail{count} = [structName '.' curr_field];
                warning([structName '.' curr_field ' failed comparison check.'])
            elseif sizeObjs > 1
                fnamesFail{count} = [structName '(' num2str(jj) ').' curr_field];
                warning([structName '(' num2str(jj) ').' curr_field ' failed comparison check.'])                
            else
               error('Size of the input object must be 1 or greater.') 
            end
            
        end
    end

end
if count % There were fields failed
    
    warning(['For the ' structName ' structure, ' num2str(count) ' field(s) ',...
        'failed the comparison. They can be found in the variable: ',...
        outputName]);
    
else % No fields failed
    disp(['All fields pass comparison check for ' structName ' structure.']);
end
end

function failFlag = compareValues(varName, val_true,val_test)
% Compares the values of two numbers/vectors/array/etc. and displays a
% warning if they are different.
% val_true - Truth value
% val_test - Value to be tested
% failFlag - Did the equality comparison fail?

failFlag = false;

if isequal(val_true,val_test) || all(all(isnan(val_true) & isnan(val_test)))
    disp([varName ' passes comparison check.']);
else
    failFlag = true;
    warning([varName ' does not pass comparison check.']);
end
end