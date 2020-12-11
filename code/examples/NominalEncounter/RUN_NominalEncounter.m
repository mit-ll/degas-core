% NominalEncounter wrapper
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% This script shows how to go through the complete simulation pipeline for
% running a two aircraft encounter

% Switch to the directory that conains the simulation
simDir = which('NominalEncounter.slx');
[simDir,~,~] = fileparts(simDir);
cd(simDir);

% Input encounter number to simulate (Number 8 for setup scenario)
encNum = 8;

% Instantiate the simulation object
s = NominalEncounterClass;

% Setup the file to read the encounters from
s.encounterFile = 'unitTestEncounters.mat';

% Setup a metadata file associated with the encounters file
s.metadataFile = 'metaData.mat';

% Setup the encounter. The encounter number is usually used as the input to
% the function to set the random seed used in the simulation
s.setupEncounter(encNum);

% Run the simulation
s.runSimulink(encNum);  

% Plot the encounter geometry
s.plot

% Read the well clear flag
s.getSimulationOutput('WCMetrics');