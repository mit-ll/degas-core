% DAAEncounter wrapper
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% This script shows how to go through the complete simulation pipeline for
% running a two aircraft encounter

% Switch to the directory that contains the simulation
simDir = which('DAAEncounter.slx');
[simDir,~,~] = fileparts(simDir);
cd(simDir);

% Input encounter number to simulate
encNum = 8;

% Instantiate the simulation object
s = DAAEncounterClass;

% Set the DAIDALUS parameters to the SC-228 Well-Clear Definition
s.daaLogic.setDaidalusToNoncoop;

% Set the Well Clear Boundary to the SC-228 Well-Clear Definition
s.wellClearMetricsParams.setWellClearToNoncoop;

% Set the Pilot Model to follow the guidance bands directly
s.uasPilot.noBufferMode = 1;

% Set the pilot to deterministic mode
s.uasPilot.deterministicMode = 1;

% Setup the file to read the encounters from
s.encounterFile = 'unitTestEncounters.mat';

% Setup the encounter
s.setupEncounter(encNum);

% Run the simulation. The encounter number is usually used as the input to
% the function to set the random seed used in the simulation
s.runSimulink(encNum);

% Plot the results
s.plot

% Plot the DAIDALUS Bands
daidalusBandViz(s);