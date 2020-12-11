% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% RUN_integration_test - Run tests on the example simulations to ensure
% that DEGAS is working as intended. This script checks to see if the
% sensors provided in the surveillanceLib are working correctly.
%
% This script runs the IntegationTestSim simulation
% located in /DEGAS/code/integration_tests/ and compares the results with
% precalculated trajectories. If there are discrepencies between the results 
% of the example simulations and the precalculated trajectories, a warning
% will be output to the Command Window. The integration test assumes that 
% IntegrationTestSim, IntegrationTestClass, and associated sensor blocks
% that they contain have not been structurally modified in any way from the
% versions in the repository. 
%
% The truth results are located in ./savedResults/all_sensors_test_results

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill out below                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% What sensor to test?
% 1 - Perfect Surveillance
% 2 - Simple Tracked Surveillance
% 3 - EOIR Parametric Model
% 4 - SC228 ADSB Model
% 5 - SC228 Tracked ADSB Model
% 6 - SC228 Active Surveillance Model
% 7 - SC228 Tracked Active Surveillance Model
% 8 - SC228 Radar Model
% 9 - SC228 Tracked Radar Model
% 10 - All sensors

selectedSensor = 10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill out above                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Pre-processing
% Run script from the directory where the script is located
simDir = which('RUN_integration_test_all_sensors.m');
[simDir,~,~] = fileparts(simDir);
cd(simDir);

clc

% Sensor names to be used for disp commands
sensor_names = ...
{'Perfect Surveillance',...
'Simple Tracked Surveillance',...
'EOIR Parametric Model',...
'SC228 ADSB Model',...
'SC228 Tracked ADSB Model',...
'SC228 Active Surveillance',...
'SC228 Tracked Active Surveillance',...
'SC228 Radar Model',...
'SC228 Tracked Radar Model',...
'all sensors'...
};

% Truth files to be used for comparision
truth_files = ...
{'sim_results_int_perf.mat',...
'sim_results_int_simp.mat',...
'sim_results_int_EOIR.mat',...
'sim_results_int_ADSB.mat',...
'sim_results_int_ADSB_tracked.mat',...
'sim_results_int_AS.mat',...
'sim_results_int_AS_tracked.mat',...
'sim_results_int_Radar.mat',...
'sim_results_int_Radar_tracked.mat',...
};

%% Run Integration simulation

if ((selectedSensor >= 1) && (selectedSensor <= 10) && (length(selectedSensor) == 1))
% Run integration simulation
    int_test_res = {};
    
    disp([newline 'Running integration test for ' sensor_names{selectedSensor} '...' newline]);
    
    if selectedSensor == 10
    % Run integration sim for all sensors
        for ii = 1:9
            int_test_res{ii} = runIntegrationSimulation(ii);
            disp(['Finished running integration sim for ' sensor_names{ii} '...']);
        end
    else
    % Run integration sim for a single sensor
        int_test_res{1} = runIntegrationSimulation(selectedSensor);
        disp(['Finished running integration sim for ' sensor_names{selectedSensor} '...']);
    end
    
    disp([newline 'Finished running all selected integration tests' newline ]);
    
else
    error('selectedSensor must be between 1 to 10.');
end

%% Compare Integration test results

if selectedSensor == 10
    passFlag = false(1,9);
else
    passFlag = false;
end

if ((selectedSensor >= 1) && (selectedSensor < 10) && (length(selectedSensor) == 1))
% Compare outputs for a single sensor
    disp([newline 'Comparing integration test results to truth values...' newline]);
    
    simObj = int_test_res{1};
    
    passFlag = compareIntegrationTestToTruth(simObj, selectedSensor, truth_files, sensor_names);

    disp(['Finished comparing integration test results to truth values for ' sensor_names{selectedSensor} '...']);
    
elseif (selectedSensor == 10) && (length(selectedSensor) == 1)
% Compare outputs for all sensors
    disp([newline 'Comparing integration test results to truth values...' newline]);
    for ii = 1:9
        simObj = int_test_res{ii};
        passFlag(ii) = compareIntegrationTestToTruth(simObj, ii, truth_files, sensor_names);  
        disp(['Finished comparing integration test results to truth values for ' sensor_names{ii} '...' newline]);
    end
else
    error('selectedSensor must be between 1 to 10.');
end

disp(['Finished comparing integration sim results to truth values for all selected sensors' newline])

%% Final Check

if ((selectedSensor >= 1) && (selectedSensor < 10) && (length(selectedSensor) == 1))

    if passFlag
        disp([sensor_names{selectedSensor} ' has been integrated correctly.' ])
    else
        warning([sensor_names{selectedSensor} ' has not been integrated correctly.' ...
                 ' Read the warnings output above.'])
    end
    
    
elseif (selectedSensor == 10) && (length(selectedSensor) == 1)
    if all(passFlag)
        disp([sensor_names{selectedSensor} ' have been integrated correctly.' ])
    else
        idx = find(~passFlag);
        for ii = 1:length(idx)
            warning([sensor_names{idx(ii)} ' has not been integrated correctly.' ...
                     ' Re-run integration test with selectedSensor set to ' ...
                      num2str(idx(ii)) ' and read warnings output.']);
        end
    end
else
    error('selectedSensor must be between 1 to 10.');
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
        'failed the comparison.']);
    
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

function s_int = runIntegrationSimulation(selectedSensor)
% All of the setup steps below are adapted from
% /DEGAS/code/examples/DAAEncounter/RUN_DAAEncounter.m

    % Clear the simulation object
    clear s_int

    % Instantiate the simulation object
    s_int = IntegrationTestClass;

    % Set the DAIDALUS parameters to the SC-228 Well-Clear Definition
    s_int.daaLogic.setDaidalusToNoncoop;

    % Set the Well Clear Boundary to the SC-228 Well-Clear Definition
    s_int.wellClearParameters.setWellClearToNoncoop;

    % Set the Pilot Model to follow the guidance bands directly
    s_int.uasPilot.noBufferMode = 1;

    % Set the pilot to deterministic mode
    s_int.uasPilot.deterministicMode = 1;
    
    % Setup the file to read the encounters from
    s_int.encounterFile = 'integrationTestEncounter.mat';

    % Setup the encounter
    s_int.setupEncounter(1);

    % Set which sensor to use
    s_int.uasSensorSelected = selectedSensor;
    
    % Skip checking the encounter for warnings
    s_int.warnings.skipCheck = true;
    
    % Run the simulation
    evalc('s_int.runSimulink(1)'); 

end

function flag = compareIntegrationTestToTruth(s_int, selectedSensor, truth_files, sensor_names)
% Compares the results of the integration test to the truth values
    
    flag = false;

    disp(['Comparing Integration Sim results to truth values for ' sensor_names{selectedSensor} '...']);

    % Clear the truth variable
    clear truth

    % Load truth data for the selected sensot
    truth = load(truth_files{selectedSensor});

    % Set the system runtime to 0 because this will always be different for
    % every run
    truth.outcome.systemTime_s = 0;

    % s_nom.outcome field cannot be manipulated directly so copying
    outcome = s_int.outcome;
    outcome.systemTime_s = 0;

    % Check if the outcome structures are equivalent
    outcomeFieldsFailed_int = compareFields('s_int.outcome',truth.outcome,outcome, 'outcomeFieldsFailed_int');

    % Check if the results structures are equivalent
    resultsFieldsFailed_int = compareFields('s_int.results',truth.results, s_int.results, 'resultsFieldsFailed_int');

    % Check if the nominal results structures are equivalent
    resultsNomFieldsFailed_int = compareFields('s_int.results_nominal',truth.results_nominal, s_int.results_nominal, 'resultsNomFieldsFailed_int');

    % Check if the daaGuidance values are equivalent
    daaFailed_int = compareValues('s_int.readFromWorkspace(''daaGuidance'')',truth.daaGuidance,s_int.readFromWorkspace('daaGuidance'));    

    % Check if the pilotModel values are equivalent 
    pilotFailed_int = compareValues('s_int.getSimulationOutput(''UAS Advisory'')',truth.pilotCommands,s_int.getSimulationOutput('UAS Advisory'));    

    % Check if the maneuverFlag values are equivalent
    manFlagFailed_int = compareValues('s_int.getSimulationOutput(''ManeuverFlag'')',truth.manFlag,s_int.getSimulationOutput('ManeuverFlag'));    

    % Check if the Well clear metrics structures are equivalent   
    wcmFailed_int = compareValues('s_int.getSimulationOutput(''WCMetrics'')',truth.WCMetrics,s_int.getSimulationOutput('WCMetrics'));    

    if (isempty(outcomeFieldsFailed_int) && ...
        isempty(resultsFieldsFailed_int) && ...
        isempty(resultsNomFieldsFailed_int) && ...
        ~wcmFailed_int && ...
        ~daaFailed_int && ...
        ~pilotFailed_int && ...
        ~manFlagFailed_int)

        flag = true;
        disp(['Integration test for ' sensor_names{selectedSensor} ' passes the integration test.'])
    else
        warning(['Integration test for ' sensor_names{selectedSensor} ' does not pass the integration test. Read warnings output above.']);
    end

end