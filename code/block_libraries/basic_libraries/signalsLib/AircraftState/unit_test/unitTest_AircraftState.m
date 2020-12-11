classdef unitTest_AircraftState < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_AircraftState Unit test for the AircraftState block
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the AircraftState block
    
    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;
            
            % Switch to the current directory
            simDir = which('unitTestAircraftState.slx');
            [simDir,~,~] = fileparts(simDir);
            cd(simDir);
            
            % Populate base workspace with bus_definitions
            bus_definitions();
        end
    end
    
    % Test Method Block
    methods (Test)
        % Test Function
        function testAircraftState(testCase)
            % Generate randomly sampled positions
            north = timeseries(5000*rand(100,1));
            east = timeseries(5000*rand(100,1));
            down = timeseries(5000*rand(100,1));
            
            assignin('base', 'north', north);
            assignin('base', 'east', east);
            assignin('base', 'down', down);
            
            %Stop time
            st = 100;
            results =  sim('unitTestAircraftState.slx', 'stoptime', num2str(st));
            
            %Ensure ENU in matches what is obtained from the aircraft state
            testCase.assertEqual(results.aircraftState.n_ft.Data(1:end-1), north.Data(1:2:end), 'AircraftState unit test failed. (n_ft not equal to expected value)');
            testCase.assertEqual(results.aircraftState.e_ft.Data(1:end-1), east.Data(1:2:end) , 'AircraftState unit test failed. (e_ft not equal to expected value)');   
            testCase.assertEqual(results.aircraftState.h_ft.Data(1:end-1), -1*down.Data(1:2:end), 'AircraftState unit test failed. (h_ft not equal to expected value)');
        end        
    end
end