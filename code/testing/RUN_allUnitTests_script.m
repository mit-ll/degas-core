% RUN_allUnitTests_script
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% This script runs the function RUN_allUnitTests, which runs all of the
% unit tests in the code/block_libraries/basic_libraries directory. Many of
% the unit tests clear the base workspace, so the user should save any
% workspace variables that they need before running this script.

%% Pre-processing
% Here the user can specify whether the RUN_allUnitTests function should
% plot or save results from select unit tests. Currently the user can
% specify to plot or save the figures for the following unit tests:
%
% Basic Aircraft Dynamics (BAD)
% EOIR Parametric Model (EOIR)
% Ownship Error (OE)
% SC228 Tracked ADSB Model (ADSB)
% SC228 Tracked Active Surveillance Model (AST)
% SC228 Tracked Radar Model (RDR)
    
plotFig_BAD = false;
plotFig_EOIR = false;
plotFig_OE = false;
plotFig_ADSB = false;
plotFig_AST = false;
plotFig_RDR = false;

saveFig_BAD = false;
saveFig_EOIR = false;
saveFig_OE = false;
saveFig_ADSB = false;
saveFig_AST = false;
saveFig_RDR = false;

% If the user would like to have all of the unit tests plot figures, set 
% the following variable to true.
plotAllFigs = false;

% If the user would like to have all of the unit tests save figures, set
% the following variable to true.
saveAllFigs = false;

%%
% Run the script from the folder where it is located
cd(fileparts(which('RUN_allUnitTests_script')));

[allTestsPassFlag, failedUnitTestNames] = RUN_allUnitTests(...
'plotAllFigs', plotAllFigs,...
'saveAllFigs', saveAllFigs ,...
'plotFig_BAD', plotFig_BAD,...
'plotFig_EOIR', plotFig_EOIR,...
'plotFig_OE', plotFig_OE,...
'plotFig_ADSB', plotFig_ADSB,...
'plotFig_AST', plotFig_AST,...
'plotFig_RDR', plotFig_RDR,...
'saveFig_BAD', saveFig_BAD,...
'saveFig_EOIR', saveFig_EOIR,...
'saveFig_OE', saveFig_OE,...
'saveFig_ADSB', saveFig_ADSB,...
'saveFig_AST', saveFig_AST,...
'saveFig_RDR', saveFig_RDR...
);