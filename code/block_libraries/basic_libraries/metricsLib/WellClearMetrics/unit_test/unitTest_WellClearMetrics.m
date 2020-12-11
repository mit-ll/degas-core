classdef unitTest_WellClearMetrics < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_WellClearMetrics Unit test for the WellClearMetrics block 
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the WellClearMetrics block
    
    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;
            
            % Switch to the current directory
            simDir = which('UnitTestWellClearMetrics.slx');
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
            myWCM = WellClearMetrics('wcm_');
            testCase.assertEqual(myWCM.tunableParameterPrefix,'wcm_',...
                'WellClearMetrics did not initialize correctly.');
        end
        function testProperties(testCase)
            myWCM = WellClearMetrics('wcm_');
            %Mod Tau
            myWCM.modTau = 35;
            %Horizontal Miss Distance
            myWCM.HMD = 4000;
            %Time of Closest Approach
            myWCM.TOCA = 0;
            %Altitude and Range Thresholds
            myWCM.altThresh = 450;
            myWCM.rangeThresh = 4000;
            
            testCase.assertEqual(myWCM.modTau,35,'modTau was not set correctly');
            testCase.assertEqual(myWCM.HMD,4000,'HMD was not set correctly');
            testCase.assertEqual(myWCM.TOCA,0,'TOCA was not set correctly');
            testCase.assertEqual(myWCM.altThresh,450,'altThresh was not set correctly');
            testCase.assertEqual(myWCM.rangeThresh,4000,'rangeThresh was not set correctly');
        end
        function testWellClearMetrics(testCase)
            %Determine whether or not a well clear violation has occurred
            %over the course of test trajectories, and if that
            %determination is made correctly.
            myWCM = WellClearMetrics('wcm_');
            myWCM.prepareSim();
            
            testdata = {'Checkcase\Headon.mat', 'Checkcase\Converging.mat'};

            for i =1:length(testdata)
               %Load the test trajectories               
               load(testdata{i});

               t_stop = size(data,1) - 1;

               %Split trajectory file into ownship/intruder
               ownTraj = [ (0:t_stop)'  data(:,[1 3 5 7 9 11]) ];  
               intTraj = [ (0:t_stop)'  data(:,[2 4 6 8 10 12])  ];
               
               assignin('base','t_stop',t_stop);
               assignin('base','ownTraj',ownTraj);
               assignin('base','intTraj',intTraj);

               %Run unit test simulation
               [ ~, ~, ~ ] = sim( 'UnitTestWellClearMetrics' );
               
               %Run comparison models
               comp1_lowc = checkcase(data);
               
               %Compare output of simulink model to the comparison model
               testCase.assertEqual(LoWC, double(comp1_lowc), 'UnitTestWellClearMetrics unit test failed. (LoWC not equal to expected value)');
            end
        end        
    end
end