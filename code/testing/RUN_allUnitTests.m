function [passFlag, failedUnitTests] = RUN_allUnitTests(varargin)
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
%% RUN_allUnitTests: Runs all unit tests in the basic_libraries directory
% This script will run all of the unit tests that are located in the
% code/block_libraries/basic_libraries directory.
% Inputs:
% varargin 'Name','Value' pairs that are described in the pre-processing section
% Outputs:
% passFlag logical value indicating if all of the unit tests pass
% failedUnitTests cell vector of the names of unit tests that failed

%% Pre-processing

% Parse the input 
p = inputParser;
addParameter(p,'plotFig_BAD',false,@islogical); % Plot figures for Basic Aircraft Dynamics unit test
addParameter(p,'plotFig_EOIR',false,@islogical); % Plot figures for EOIR Sensor Model unit test
addParameter(p,'plotFig_OE',false,@islogical); % Plot figures for Ownship Error unit test
addParameter(p,'plotFig_RDR',false,@islogical); % Plot figures for SC228 Tracked Radar unit test
addParameter(p,'plotFig_ADSB',false,@islogical); % Plot figures for SC228 Tracked ADSB unit test
addParameter(p,'plotFig_AST',false,@islogical); % Plot figures for SC228 Active Surv. unit test

addParameter(p,'saveFig_BAD',false,@islogical); % Save figures for Basic Aircraft Dynamics unit test
addParameter(p,'saveFig_EOIR',false,@islogical); % Save figures for EOIR Sensor Model unit test
addParameter(p,'saveFig_OE',false,@islogical); % Save figures for Ownship Error unit test
addParameter(p,'saveFig_RDR',false,@islogical);  % Save figures for SC228 Tracked Radar unit test
addParameter(p,'saveFig_ADSB',false,@islogical); % Save figures for SC228 Tracked ADSB unit test
addParameter(p,'saveFig_AST',false,@islogical); % Save figures for SC228 Active Surv. unit test

addParameter(p,'plotAllFigs',false,@islogical); % Plot all figures
addParameter(p,'saveAllFigs',false,@islogical); % Save all figures

parse(p,varargin{:});

% These variables indicate if the unit tests should generate or save plots
% Each variable is saved in the .mat file unitTestParams.mat in the
% code/testing directory
plotFig_BAD = p.Results.plotFig_BAD;  
plotFig_EOIR = p.Results.plotFig_EOIR; 
plotFig_OE = p.Results.plotFig_OE;   
plotFig_RDR = p.Results.plotFig_RDR;  
plotFig_ADSB = p.Results.plotFig_ADSB; 
plotFig_AST = p.Results.plotFig_AST;  

saveFig_BAD = p.Results.saveFig_BAD;  
saveFig_EOIR = p.Results.saveFig_EOIR; 
saveFig_OE = p.Results.saveFig_OE;   
saveFig_RDR = p.Results.saveFig_RDR; 
saveFig_ADSB = p.Results.saveFig_ADSB; 
saveFig_AST = p.Results.saveFig_AST;  

if p.Results.plotAllFigs
    plotFig_BAD = true;
    plotFig_EOIR = true;
    plotFig_OE = true;
    plotFig_RDR = true;
    plotFig_ADSB = true;
    plotFig_AST = true;
end

if p.Results.saveAllFigs
    saveFig_BAD = true;
    saveFig_EOIR = true;
    saveFig_OE = true;
    saveFig_RDR = true;
    saveFig_ADSB = true;
    saveFig_AST = true;
end

% Save these parameters into a mat file in the code/testing directory
save([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],...
'plotFig_BAD','plotFig_EOIR','plotFig_OE','plotFig_RDR','plotFig_ADSB','plotFig_AST',...
'saveFig_BAD','saveFig_EOIR','saveFig_OE','saveFig_RDR','saveFig_ADSB','saveFig_AST')

% Get current directory
curr_dir = pwd;

% Array of all test vectors
testResults_all = [];

% Outputs
% passFlag is false until all unit tests pass
passFlag = false;

% Cell vector of which unit tests fail
failedUnitTests = {};
%%
    % Get all of the unit test directories in the 
    % code/block_libraries/basic_libraries directory
    dirList_unit_tests = dir([getenv('DEGAS_HOME')...
        filesep 'block_libraries' filesep 'basic_libraries' filesep...
        '**' filesep 'unit_test']);

    dirList_unit_tests = unique(extractfield(dirList_unit_tests,'folder'));
    
    numTests = length(dirList_unit_tests);
    
    disp('Running all unit tests in DEGAS/code/block_libraries/basic_libraries...');
    
    for ii = 1:numTests
        
        disp(['Running unit test ' num2str(ii) ' out of ' num2str(numTests)]);
        
        % Clear existing unit test
        if exist('suite','var')
            clear suite
        end
        
        % Switch to unit test directory
        cd(dirList_unit_tests{ii});
        
        % Load all unit tests in current directory
        suite = testsuite(pwd,'Name','unitTest_**');

        % Run unit tests
        testResults = run(suite);
        
        % Concat
        testResults_all = [testResults_all, testResults];
    end

    % Did all the tests pass?
    passFlag = all([testResults_all.Passed]);
    
    % Which tests failed? 
    testNames = {testResults_all.Name};    
    failedUnitTests = testNames(~[testResults_all.Passed]);
    
    if passFlag
        disp('All unit tests passed!');
    else
        disp(['At least one unit test failed. Please check the '...
              'failedUnitTestNames variable.']);
    end
    
    cd(curr_dir);

    %Turn visibility back on
    set(0, 'DefaultFigureVisible', 'on');
end