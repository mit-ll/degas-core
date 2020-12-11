%% 
% Startup script
% Copyright 2008 - 2020, MIT Lincoln Laboratory
%
% SPDX-License-Identifier: X11
%
% This script is run whenever DEGAS is launched. It generates and adds
% all paths in the ./DEGAS/code directory to the MATLAB Path. Additional
% paths can be added by this startup script by populating the addThesePaths
% cell.

[temp, ~, ~] = fileparts(which('startup.m'));

cd(temp);

disp(['Running DEGAS startup script...' '(' which('startup') ')'] );

% Check MATLAB script
matlabVer = ver('MATLAB');
if ~strcmp(matlabVer.Release,'(R2018b)')
    warning( [ 'DEGAS officially supports MATLAB R2018b.  You are using ' matlabVer.Release ] );
end

% Adding additional paths
addThesePaths = {...
    ['..' filesep '..' filesep 'DAIDALUS-with-LL-Interfaces' filesep 'SimulinkInterface'];...
    ['..' filesep '..' filesep 'UasPilotModelv6']...
    };

if ~isempty(addThesePaths)
    disp('Adding additional paths...');
    
    for ii = 1:length(addThesePaths)
        if exist(addThesePaths{ii},'dir')
            disp(['Adding ' addThesePaths{ii} ' to path...']);
            addpath(genpath(addThesePaths{ii}));
        else
            disp([addThesePaths{ii} ' is not a valid directory, not adding to path']);
        end
    end
end

% Set Up
curDir = pwd;
err = [];

try
    dir = fileparts(which('startup'));
    cd(dir); % Make sure in top level directory
    
    % Set environment variable DEGAS_HOME
    setenv( 'DEGAS_HOME', pwd() );
    
    % Set path
    addpath(fullfile(pwd(), 'utilities'));
    addpath(genpath_degas(pwd()));
    
    % Set up Simulink buses
    bus_definitions;
    
    % Set up shell executable path
    if ismac
        setenv( 'PATH', [ getenv('PATH') pathsep '/usr/X11/bin' ] ); % so can find xterm
    end
    
catch err
end

cd(curDir);
clear curDir dir;
if( ~isempty( err ) )
    rethrow(err);
end
clear err ii addThesePaths matlabVer temp;
% Everything is done
disp('Done!');