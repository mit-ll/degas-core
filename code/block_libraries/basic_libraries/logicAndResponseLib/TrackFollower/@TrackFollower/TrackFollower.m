classdef TrackFollower < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% TrackFollower: Implements the tunable parameters for the
% TrackFollower block located in TrackFollowerBlock.slx

    properties
        trajFileName = 'traj.mat' % .mat file that holds the NED trajectory 
        % data. The .mat file should contain a variable called 'traj'. 
        % 'traj' should be a 7xN array of values that contain the 
        % trajectory data to be followed. Row 1 is the time in seconds, 
        % row 2 is the North position in ft, row 3 is the East position in
        % feet, row 4 is the altitude in feet, row 5 is the North velocity
        % in ftps, row 6 is the East velocity in ftps, and row 7 is the
        % altitude change in ftps
        
        TrackFollowerLocation = '' % Location of the TrackFollower Block 
        % in the end-to-end simulation. For example, if the Track Follower
        % block is in the Ownship Dynamics and Trajectory subsystem in
        % DAAEncounter.slx, TrackFollowerLocation is 'DAAEncounter/Ownship 
        % Dynamics and Trajectory'
        
        SimulinkModelName = '' % The name of the Simulink model. i.e. for 
        % DAAEncounter.slx, the SimulinkModelName is 'DAAEncounter'
        
        con @ dynamicsConstraints % Dynamic constraints bounding state and 
        % state rate outputs
        
    end

    methods
        function obj = TrackFollower(tunableParameterPrefix,varargin)
        % TrackFollower Constructor for the TrackFollower_Class. This
        % object must be constructed such that the properties 
        % TrackFollowerLocation and SimulinkModelName are set at
        % initialization. The example below shows how to initialize the
        % object
        %
        % T = TrackFollower('ac1trckflwr_',...
        %                         'TrackFollowerLocation','DAAEncounter/Ownship Dynamics and Trajectory',...
        %                         'SimulinkModelName','DAAEncounter');
        %
        
            if( nargin < 1 )
                tunableParameterPrefix = '';
            end

            obj.con = dynamicsConstraints();

            p = inputParser;
            
            % Required parameters
            addRequired(p,'tunableParameterPrefix',@ischar);

            addParameter(p, 'trajFileName', obj.trajFileName, @ischar);
            addParameter(p, 'TrackFollowerLocation', obj.TrackFollowerLocation, @ischar);
            addParameter(p, 'SimulinkModelName', obj.SimulinkModelName, @ischar);
            
            parse(p,tunableParameterPrefix,varargin{:});

            fieldsSet = intersect( fieldnames(p.Results), fieldnames(obj) );
            for i = 1:1:numel(fieldsSet)
                obj.(fieldsSet{i}) = p.Results.(fieldsSet{i});
            end
            obj.TrackFollowerCheck();
            obj.SimulinkModelNameCheck();
            obj.setTrajFileNameInSimulinkModel();
        end
%% Setters
% Setter functions set the value of the property of the object by calling
% the appropriate set function. The set functions have input handling built
% in so that the value the property is set to is valid. Like the
% aforementioned getter functions, the setter functions are not called
% explicitly, i.e. running "simObj.ac1TrckFlwr.trajFileName = ''" in the
% command line will call set.trajFileName(obj, value)

        function set.trajFileName(obj, value)
            if ischar(value) && contains(value((end-3):end),'.mat')
                obj.trajFileName = value;
            else
                error('trajFileName must be the name of a .mat file')
            end
        end
        function set.TrackFollowerLocation(obj,value)
            if ischar(value)
                obj.TrackFollowerLocation = value;
            else
                error('TrackFollowerLocation must be the location of the Track Follower block in the end-to-end Simulink model.')
            end
        end
        function set.SimulinkModelName(obj,value)
            if ischar(value)
                obj.SimulinkModelName = value;
            else
                error('SimulinkModelName must be the name of the Simulink Model used in the end-to-end simulation class.')
            end            
        end
%% Additional functions
        function TrackFollowerCheck(obj)
            if (isempty(obj.TrackFollowerLocation))
                error('TrackFollowerLocation must be set to the location of the Track Follower block.')
            end
        end
        function SimulinkModelNameCheck(obj)
            if (isempty(obj.SimulinkModelName))
                error('SimulinkModelName must be set to name of the end-to-end simulation Simulink Model.')
            end
        end
        function setTrajFileNameInSimulinkModel(obj)
            load_system(obj.SimulinkModelName);
            set_param(...
                      strcat(...
                             obj.TrackFollowerLocation,...
                             '/Track Follower/Follow Trajectory Wrapper/Follow Trajectory/Get Trajectory Data/From File'),...
                      'FileName',obj.trajFileName)
            save_system(obj.SimulinkModelName)
            close_system(obj.SimulinkModelName)            
        end
    end
end