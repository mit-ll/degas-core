classdef BasicSimulation < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% BasicSimulation: BasicSimulation contains the necessary functions and 
% properties to run an end-to-end simulation created by the user.
%
% BasicSimulation 
% Makes NO assumptions about the outputs or contents of the model.
% Most simulations should be derived from subclass Simulation.
    
    %% Constructor
    methods
        function obj = BasicSimulation( model_name )
            %Construct a new DEGAS Simulation object
            %
            %   obj = Simulation( model_name )
            %
            % model_name - Base of Simulink model name.  example: 'NominalEncounter'
            
            bus_definitions(); % Put bus definitions in base workspace
            
            obj.modelName = model_name;
           
        end
    end    
    %% Properties
    properties (SetAccess = 'private' )
        modelName; % Based on the Simulink model name (NominalEncounter.slx) -> NominalEncounter
    end
    properties (GetAccess = 'public', SetAccess = 'public')
        runTime_s = 600; % Maximum simulated time
        maxDataPoints = 10000; % Maximum number of output samples to retain
        fastRestartMode = false; % Should the simulation be run in fast restart mode?
        tempFileNameSet = false; % Is the temporary file name set?
    end % end properties
    
    properties(Abstract = true, Access = 'public')
        eventFileNames; % Name of event files (default {'event1', 'event2'})
    end 
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        % Initialize the results and outcome structures
        % allow the user to see results and outcome, but not to set values.
        % Only the sim may set values.

        % Time trajectories of select quantities computed during the simulation
        results = repmat( struct(...
            'time',[], ...     % Simulation time vector
            'north_ft',[],...  % North position
            'east_ft',[],...   % East position
            'up_ft',[], ...    % Up position
            'speed_ftps', [], ... % Aircraft speed
            'psi_rad',[],...   % Heading
            'theta_rad',[],... % Pitch angle
            'phi_rad',[],...   % Bank angle
            'vertical_speed_ftps',[],... % vertical speed
            'hdd_ftps2',[],... % Vertical acceleration
            'AvoidFlag',[],... % True when a self-separation or collision avoidance logic is indicating something other than clear-of-conflict
            'altitude_ft',[]...% Aircraft altitude
            ), [ 2 1 ] );
        
        % Time trajectories of select quantities computed during the simulation of a nominal trajectory
        results_nominal = repmat( struct('time',[],'north_ft',[],'east_ft',[],...
            'altitude_ft',[],'speed_ftps',[],'psi_rad',[],'theta_rad',[],'phi_rad',[],'vertical_speed_ftps',[],...
            'hdd_ftps2',[],...                        
            'AvoidFlag',[]), [ 2 1 ] );

        % Time trajectories of sensor estimates
        estimates = repmat( struct('time',[], ...
                                   'latLonAltEst',[],...     % Struct that contains latitude, longitude, and altitude estimates
                                   'timeOfValidity',[],...   % Time of the estimate
                                   'isValid',[],...          % Is the track valid?
                                   'enuStateEstimate',[],... % Struct that contains estimates of East-North-Up coordinates
                                   'covEstimate',[]...       % Covariance estimate
                                   ), [ 2 1 ] );        
        
        % The value of metrics summarizing the outcome of the simulated encounter
        outcome = struct('systemTime_s', []); % Fields determined by what MetricBlocks are included in the derived class
        
    end % end properties
    methods
        function clearResults( this )
            % Clear values in results and outcome structures from previous
            % runs
            for aidx = 1 : numel(this.results),
                for fn = fieldnames(this.results)',
                    this.results(aidx).(fn{1}) = [];
                end
            end
        
            % If previously simulated the nominal trajectory and now are
            % simulating the equipped trajectory, we don't want to discard
            % the nominal trajectory!
            if( this.isNominal() )
                for aidx = 1 : numel(this.results_nominal),
                    for fn = fieldnames(this.results_nominal)',
                        this.results_nominal(aidx).(fn{1}) = [];
                    end
                end
            end
        
            this.outcome = struct();
        end
    end
    properties(SetAccess=private,Hidden)
        metricBlocks@MetricBlock; % All the MetricBlocks that have registered to provide metrics at end of simulation
    end
    methods
        function this = registerMetricBlock( this, mblock )
        % Adds a MetricBlock object to the list of blocks to call in
        % retrieveMetrics
            this.metricBlocks = cat( 1, this.metricBlocks, mblock );
        end
    end
    
    methods(Access=private)
        function this = retrieveMetrics(this)
            % Pull out all metrics from registered MetricBlock objects
            % and place them in this.outcome
            for k = 1 : numel(this.metricBlocks),
                this.outcome = this.metricBlocks(k).addMetrics( this.outcome );
            end  
        end
    end    
    
    %% Abstract Methods
    methods(Abstract = true, Access = 'public')
        isNominal (obj); % Should return true when the simulation is configured to simulate the "nominal" (unequipped) trajectories
    end %End methods
    
    methods(Access=private)
        function this = initializeRandomNumberGenerator( this, seedValue )
            % Sets the global random seed used by the simulation
            if isempty(seedValue)
                warning('No seed supplied. Results may be non-deterministic.');
            else
                rng(seedValue,'twister'); % Set global random seed
            end
        end
    end
    
    %% Run Simulation Locally
    methods        
        function SimOut = runSimulink(obj, randSeed, genRandomFileNames)
            % Calculate results and outcome using the Simulink model
            %   
            %   SimOut = theSim.runSimulink()
            %   SimOut = theSim.runSimulink(randSeed)
            %   
            %   randSeed - Optional random seed for all random quantities.
            %      Often set to the encounter number.
            %   
            %   genRandomFileNames - Optional flag to generate random event
            %   file names. Useful for running many encounters in parallal.

            if ~exist('randSeed','var')
                randSeed = []; % default value of randSeed
            end

            if ~exist('genRandomFileNames','var')
                genRandomFileNames = false; % default value of genRandomFileNames
            end            
            if( nargin < 2 )
                randSeed = [];
            end     
            
            obj.initializeRandomNumberGenerator( randSeed );
            
            obj.clearResults();
            
            if genRandomFileNames            
                eventFiles = obj.writeEventFiles(true); % Write to randomly generated file names
            else                
                eventFiles = obj.writeEventFiles(false); % Write to file names event1.mat, event2.mat and so on                
            end
            
            obj.eventFileNames{1} = eventFiles(1).file;
            obj.eventFileNames{2} = eventFiles(2).file;
            
            % Notify all objects that simulation is about to start 
            obj.onSimulationStart( obj );
            
            disp('Running Simulation');
            
            % Prepare aircraft for simulation and set tunable parameters
            obj.prepareSim();                       
                 
            SaveFormat = 'Dataset';
            
            tic;
            
            SimOut = sim(obj.modelName,  ...
                'StopTime', num2str(obj.runTime_s), ...
                'SaveTime', 'on', 'TimeSaveName', 'tout', ...
                'SaveState','on','StateSaveName','xoutNew',...
                'SaveOutput','on','OutputSaveName','youtNew',...
                'SaveFormat',SaveFormat, 'MaxDataPoints', num2str(obj.maxDataPoints) );  
            
            obj.outcome.systemTime_s = toc;    
         
            obj.simOut = SimOut;
            
            obj.onSimulationComplete( obj );
        end
        
        function SimOut = runSimulinkFast(obj, randSeed, genRandomFileNames)
            % Calculate results and outcome using the Simulink model in
            % Fast Restart Mode
            %   
            %   SimOut = theSim.runSimulink()
            %   SimOut = theSim.runSimulink(randSeed)
            %   
            %   randSeed - Optional random seed for all random quantities.
            %      Often set to the encounter number. Default value [];
            % 
            %   genRandomFileNames - Optional flag to generate random event
            %   file names. Useful for running many encounters in parallal.

            if ~exist('randSeed','var')
                randSeed = []; % default value of randSeed
            end

            if ~exist('genRandomFileNames','var')
                genRandomFileNames = false; % default value of genRandomFileNames
            end
            
            obj.initializeRandomNumberGenerator( randSeed );
            
            obj.clearResults();
            
            if genRandomFileNames
                % This option is primarily for running multiple jobs using
                % an embarassingly parallal approach. If multiple instances
                % of Matlab are running from the same dirctory, there are
                % conflicts when all of them write events to 'event1.mat'
                % and 'event2.mat'. Using randomly generated file names
                % fixes this issue.
                eventFiles = obj.writeEventFiles(true); % Write to randomly generated file names
            else                
                eventFiles = obj.writeEventFiles(false); % Write to file names event1.mat, event2.mat and so on                
            end
            
            obj.eventFileNames{1} = eventFiles(1).file;
            obj.eventFileNames{2} = eventFiles(2).file;               
            
            obj.fastRestartMode = true;
            
            % Notify all objects that simulation is about to start 
            obj.onSimulationStart( obj );
            
            disp('Running Simulation');
            
            % Prepare aircraft for simulation and set tuneable parameters
            obj.prepareSim();              
            
            tic;
            
            SimOut = sim(obj.modelName, 'StopTime', num2str(obj.runTime_s));                
            
            obj.outcome.systemTime_s = toc;    
         
            obj.simOut = SimOut;
            
            obj.onSimulationComplete( obj );
            
            if genRandomFileNames
                if ~obj.tempFileNameSet
                    obj.tempFileNameSet = true;
                end
            end
            
        end
        
    end
    
    methods
        function values = getSimulationOutput( this, outPortName )
            % Returns top-level output signals
            % When last run was in Simulink (method runSimulink), returns
            % the trace of values sent to the top-level Out Port block of
            % the given name
            %
            %   values = getSimulationOutput( this, outPortName )
            %
            % Returns a matrix in which the first dimension (row) is time
           
            if( isstruct( get( this.simOut, 'youtNew' ) ) )
           
                signals = get( this.simOut, 'youtNew' );
                signals = signals.signals;
                outputNames = { signals.blockName };
                stateOutputIdx = strcmp( outputNames, [ this.modelName '/' outPortName  ] );
                if( all(~stateOutputIdx) )
                    error( [ 'Top level Out Port block "' outPortName '" not found' ] );
                end
                values = signals(stateOutputIdx).values;
                return;
            end
            
            tsstruct = getSimulationOutputTimeseries( this, outPortName );
            
            if( isstruct( tsstruct ) )
                c = struct2cell( tsstruct );
                % Recursively expand bus structures until we have a cell
                % array of timeseries
                while( any( cellfun( @isstruct, c ) ) )
                    for k = 1 : numel( c ),
                        if( isstruct( c{k} ) )
                            c = cat( 1, c(1:(k-1)), struct2cell( c{k} ), c((k+1):end) );
                        end
                    end
                end
                
                % Turn into a matrix of data values
                c = cellfun( @(x) x.Data, c, 'UniformOutput', false );
                
                % Can't concatenate if all signals do not contain the same
                % number of samples
                numSamples = cellfun( @(x) size(x,1), c );
                if( not( all( numSamples == numSamples(1) ) ) )
                    error(  [ 'Not all signals logged at out port ' outPortName ' have same number of samples.  Mixed sample times not supported by getSimulationOutputTimeseries().' ] );
                end     
                
                % Loss of precision if we concatenate differing types (e.g.
                % double and uint32) (acceptable exception is logical type)
                signalTypes = cellfun( @(x) class(x), c, 'UniformOutput', false );
                signalTypes( strcmp( signalTypes, 'logical' ) ) = []; % leave logicals out of it
                if( not(isempty(signalTypes)) )
                if( not( all( strcmp( signalTypes, signalTypes{1} ) ) ) )
                    error( [ 'Bus output ' outPortName ' has mixed signals and is therefore not supported by getSimulationOutput(). (Prevent loss of precision in double-->int conversion).' ] );
                end
                end
                
                values = cat( 2, c{:} );
            else
                % Non-bus signal
                values = tsstruct.Data;
            end
        end    
    
        function ts = getSimulationOutputTimeseries( this, outPortName )
            % Returns top-level output signals
            % When last run was in Simulink (method runSimulink), returns
            % the trace of values sent to the top-level Out Port block of
            % the given name
            %
            %   ts = getSimulationOutputTimeseries( this, outPortName )
            %
            % Returns a timeseries or structure of timeseries (for bus types)
            
            youtNew = get( this.simOut, 'youtNew' );
            assert( not( isstruct( youtNew ) ), 'getSimulationOutputTimeseries() only supports Simulink SaveFormat "Dataset"' );
            signal = youtNew.get( [ this.modelName '/' outPortName ], '-blockpath' );
            if( isempty( signal ) )
                error( [ 'Top level Out Port block "' outPortName '" not found' ] );
            end
            ts = signal.Values;            
        end
    end        
    
    methods
        % Override
        function onSimulationComplete( obj, simObj )   
            
            % First let commonMetrics and other child objects update
            % themselves
            obj.onSimulationComplete@DEGAS( simObj );
            
            % Pull out all metrics
            obj.retrieveMetrics();
            
        end
    end        
    methods                
        function setupSim(obj,currScenario,varargin) %#ok<INUSD> Abstract method but with optional implementation
            % Setup the simulation for a given scenario
            %
            % Set all simulation parameters that remain constant for all
            % tasks/encounters
        end        
    end
    
    
    
    %% Helper methods
    properties%(Access=protected)
        simOut % Contents of output from the last simulation run (returned by call to "sim")
    end
    methods
        function val = readFromWorkspace( obj, varname )
            %READFROMWORKSPACE Retrive a value sent to a Simulink "To Workspace" block
            %
            %    val = readFromWorkspace( obj, varname )
            %
            % This method retrieves the value that was stored in the
            % Simulink model by a Simulink "To Workspace" block with the
            % variable name set to the supplied argument "varname".  If the
            % model was run with a call to runSimulink or runSimulinkFast
            % it is read from the base workspace. 
            %
            % Note that this method can only called after method
            % runSimulink or runSimulinkFast has been called.  
            
            val = obj.simOut.get(varname);
            if( isempty( val ) )
                % Maybe it really is empty, or maybe we asked for a
                % variable that wasn't in the simulation results, in
                % which case there is probably something wrong
                varNames = obj.simOut.who();
                if( ~any( strcmp( varNames, varname ) ) )
                    error( [ 'Requested simulation output ' varname ' not found' ] );
                end
            end                     
        end
    end    
    
    %% Setters
    methods
        function set.modelName(obj, value)
            if ~ischar(value)
                error('Invalid modelName')
            end
            obj.modelName = value;
        end
        
        function set.runTime_s(obj, value)
            if ~isnumeric(value) || (value <= 0)
                error('Invalid runTime_s')
            end
            obj.runTime_s = value;
        end
        
        function set.fastRestartMode(obj, value)
            if ~islogical(value)
                error('Invalid fastRestartMode');
            end
            obj.fastRestartMode = value;
            if obj.fastRestartMode
                if ~any(strcmp(find_system('SearchDepth', 0),obj.modelName))
                    load_system(obj.modelName);
                end
                set_param(obj.modelName ,'FastRestart','on');                
            else
                if any(strcmp(find_system('SearchDepth', 0),obj.modelName))
                    set_param(obj.modelName ,'FastRestart','off');                    
                end                
            end
        end        
        
    end % End methods    
 
    
    %% Event control signal (simulation model input) handling
    methods(Abstract = true, Access = protected)
        
        % Must return a cell array containing the event matrix for every aircraft
        eventScripts = getEventMatrices( this )
         % Must return a cell array containing the event matrix for every aircraft
         %
         % The event matrix = [ time_s(:) verticalRate_fps(:) turnRate_radps(:) longitudeAccel_ftpss(:)]
    end
    methods(Abstract = true)
        % Configure simulation to use provided nominal trajectories (initial states and control update scripts)
        this = setupEncounter( this, encounter, varargin )
         % Load the nominal trajectories (initial states and control
         % update scripts) into the simulation
         %
         %    theSim.setupEncounter( encounter )
         %
         %  where encounter is an object of type ScriptedEncounter
         %   
    end %End methods
    
    methods
        function eventFiles = writeEventFiles( this, genRandomFileNames )
            % Find EncounterModelEvent class and create event matrices for 
            % nominal trajectory
            %
            %   % Write to event1.mat, event2.mat and so on
            %   eventFiles = theSim.writeEventFiles() 
            %   
            %   % Write to randomly generated file names
            %   eventFiles = theSim.writeEventFiles( true )
            %
            % Returns array of temporaryfile objects that delete the event
            % files upon object deletion.  You must save this return to a
            % variable or the event files will be immediately deleted.  
            %
            % Assumes that all Nominal Trajectory blocks are using the
            % scheme "eventN.mat" for the event files, where N is the
            % one-based aircraft index.  
            
            if( nargin < 2 )
                genRandomFileNames = false;
            end
            
            eventMats = this.getEventMatrices(); % Get event matrices for all aircraft
            eventFiles = temporaryfile.empty();
            for ac = 1 : numel(eventMats),
                if( genRandomFileNames )
                    if this.tempFileNameSet
                        currDir = pwd;                        
                        [filePath,fileName,~] = fileparts(this.eventFileNames{ac});
                        cd(filePath)
                        eventFiles(ac) = temporaryfile( fileName, '.mat' );
                        cd(currDir);
                    else
                        eventFiles(ac) = temporaryfile( [], '.mat' );
                    end
                else
                    eventFiles(ac) = temporaryfile( [ 'event' num2str(ac) '.mat' ] );
                end
                event = eventMats{ac}'; %#ok event used in save command
                save( eventFiles(ac).file, '-v6', 'event' );
            end
        end
        
    end % METHODS   
end % End classdef