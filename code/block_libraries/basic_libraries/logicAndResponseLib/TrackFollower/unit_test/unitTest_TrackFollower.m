classdef unitTest_TrackFollower < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_TRACKFOLLOWER Unit test for the TrackFollower block
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the TrackFollower block
    
    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;
            
            % Switch to the current directory
            simDir = which('unitTestTrackFollower.slx');
            [simDir,~,~] = fileparts(simDir);
            cd(simDir);
            
            % Populate base workspace with bus_definitions
            bus_definitions();
        end
    end
    
    % Test Method Block
    methods (Test)
        % Test Function
        function testConstructor(testCase)
            %Intialize the class. Must ensure location and Simulink
            %Model name valid.
            myTF = TrackFollower('ac1trckflwr_',...
                'TrackFollowerLocation','unitTestTrackFollower',...
                'SimulinkModelName','unitTestTrackFollower');
            
            testCase.assertEqual(myTF.tunableParameterPrefix,'ac1trckflwr_',...
                'TrackFollower did not initialize correctly.');
        end
        function testTrackFollower(testCase)
           ac1 = BasicAircraftDynamics('ac1trckflwr_');
           ac1.prepareSim();
            
           myTF = TrackFollower('ac1trckflwr_',...
           'trajFileNam', 'traj1.mat',...
           'TrackFollowerLocation','unitTestTrackFollower',...
           'SimulinkModelName','unitTestTrackFollower');  
        
           myTF.prepareSim();
            
           traj1 = open('traj1.mat');
           assignin('base','traj1', traj1);
                              
           [~, ~, ~] = sim('unitTestTrackFollower');
           
           %Obtain values from trajectory files 
           n_ft = traj1.Data(:,1);
           e_ft = traj1.Data(:,2);
           h_ft = traj1.Data(:,3);
           ndot_ftps = traj1.Data(:,4);
           edot_ftps = traj1.Data(:,5);
           hdot_ftps = traj1.Data(:,6);
           
           %Ensure values output from sim match those from the trajectory
           %file.
           testCase.assertEqual(state.n_ft.Data, n_ft, "Track Follower Unit Test Failed. (n_ft was not computed correctly)");
           testCase.assertEqual(state.e_ft.Data, e_ft, "Track Follower Unit Test Failed. (e_ft was not computed correctly)");
           testCase.assertEqual(state.h_ft.Data, h_ft, "Track Follower Unit Test Failed. (h_ft was not computed correctly)");
           testCase.assertEqual(stateRate.Ndot_ftps.Data, ndot_ftps, "Track Follower Unit Test Failed. (ndot_ftps was not computed correctly)");
           testCase.assertEqual(stateRate.Edot_ftps.Data, edot_ftps, "Track Follower Unit Test Failed. (edot_ftps was not computed correctly)");
           testCase.assertEqual(stateRate.hdot_ftps.Data, hdot_ftps, "Track Follower Unit Test Failed. (hdot_ftps was not computed correctly)");
        end        
    end
end