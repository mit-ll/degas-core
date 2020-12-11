% RUN_metrics_code
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% This script loads aggregrate results, and calculates and checks 
% the risk ratio and Loss of Well Clear (LoWC) ratio using the functions 
% provided in the metrics_calc and metrics_check directories. There are
% sample results provided in the ./sample_results folder. The user can
% provide their own results to this script. To do that, change the 
% variables 'nominal_results_file' and 'mitigated_results_file' in the
% section below to point to the users results.
%
% For reference, the definitions of risk ratio and LoWC ratio are given
% below:
%
%
%                P(NMAC with avoidance logic | Encounter)
% risk ratio = --------------------------------------------
%               P(NMAC without avoidance logic | Encounter)
%
% NMAC - Near mid-air collision (500 ft. horizontal separation and 100 ft.
% vertical separation)
%
%                P(LoWC with avoidance logic | Encounter)
% LoWC ratio = --------------------------------------------
%               P(LoWC without avoidance logic | Encounter)

%% Preprocessing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill out below                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Path to nominal results
nominal_results_file = './sample_results/results_nom.mat';

% Path to mitigated results
mitigated_results_file = './sample_results/results_mit.mat';

% Weights
% The user can either specify the variable 'weights' or load the variable
% 'weights' from the weights file. For example:
% weights = ones(1,10000); % All weights are 1
% or
weights_file = './sample_results/weights.mat';

% LoWC HMD treshold 
% Fill this out only if the LoWC bound was different from the default 
% 4000 ft.
% If the treshold is the default, set 'LoWC_HMD_tresh' as such:
% LoWC_HMD_tresh = '';
LoWC_HMD_tresh = 2200;

% Which indices to use fo calculating risk ratio and LoWC ratio
% default value should be a logical vector of true values whose length is
% equal to the number of encounters
indices = true(1,10000);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fill out above                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load results

% Switch to directory where this file is located
simDir = which('RUN_metrics_code');
[simDir,~,~] = fileparts(simDir);
cd(simDir);

% The user can load their own results. ./sample_results holds sample
% nominal and mitigated results
if ~exist(nominal_results_file,'file')
    error([newline, 'The nominal results file cannot be found.', newline ]);
else
    % Nominal results
    res_nom = load(nominal_results_file);    
    disp('Nominal results loaded.');
end

if ~exist(nominal_results_file,'file')
    error([newline, 'The mitigated results file cannot be found.', newline ]);
else
    % Mitigated results
    res_mit = load(mitigated_results_file);   
    disp('Mitigated results loaded.');    
end

if exist('weights_file','var')
    load(weights_file);
    if ~exist('weights','var')
        warning(['weights variable not found in workspace! '...
        'Make sure there is a variable weights in the '... 
        'file specified by weights_file.']);
    else
        disp('Weights file loaded.');
    end
else
    if ~exist('weights','var')
        warning('No weights variable found in base workspace.');
    end
end

%% Check if the HMD/VMD distribution is larger than the NMAC and LoWC bounds

% Find which rows in the data field have hmd and vmd data
hmd_idx = find(contains(res_mit.fields,'hmd_ft'));
vmd_idx = find(contains(res_mit.fields,'vmd_ft'));

% Get HMD and VMD data
hmds = res_mit.data(hmd_idx,:);
vmds = res_mit.data(vmd_idx,:);

% Check the NMAC bounds. If the HMD/VMD distribution is entirely within the
% NMAC region, a warning will be issued
warningFlag_NMAC = checkNmacBounds(hmds,vmds);

% Check the NMAC bounds. If the HMD/VMD distribution is entirely within the
% NMAC region, a warning will be issued
if ~isequal(LoWC_HMD_tresh, '')
    warningFlag_Lowc = checkLowcBounds(hmds,vmds,'hmdTresh',LoWC_HMD_tresh);
else
    warningFlag_Lowc = checkLowcBounds(hmds,vmds);
end

%% Calculate the risk ratio and Lowc ratio

% Find which row in the data has nmac data
nmac_idx = find(contains(res_mit.fields,'nmac'));

% Get nominal and mitigated nmacs
nmacs_nom = res_nom.data(nmac_idx,:);
nmacs_mit = res_mit.data(nmac_idx,:);

% Calculate risk ratio (The inputs to the function are expected to be logical vectors)
[risk_ratio, risk_ratio_ci] = calcRiskRatio(logical(nmacs_mit), logical(nmacs_nom),'weights',weights,'indices',indices)

% Find which row in the data has LoWC data
lowc_idx = find(contains(res_mit.fields,'wcv'));

% Get nominal and mitigated LoWC
lowc_nom = res_nom.data(lowc_idx,:);
lowc_mit = res_mit.data(lowc_idx,:);

% Calculate LoWC ratio (The inputs to the function are expected to be logical vectors)
[lowc_ratio, lowc_ratio_ci] = calcLowcRatio(logical(lowc_mit), logical(lowc_nom),'weights',weights,'indices',indices)
