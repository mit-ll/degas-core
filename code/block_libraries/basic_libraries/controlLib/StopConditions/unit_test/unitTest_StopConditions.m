classdef unitTest_StopConditions < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_STOPCONDITIONS Unit test for the StopConditions block
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the StopConditions block
    
    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;
            
            % Switch to the current directory
            simDir = which('StopConditions_UnitTest.slx');
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
            myStop = StopConditions('');
            testCase.assertEqual(myStop.tunableParameterPrefix,'',...
                'StopConditions did not initialize correctly.');
        end
        function testProperties(testCase)
            myStop = StopConditions('');
            myStop.stop_range_ft = 1000;
            myStop.stop_altitude_ft = 5000;
            testCase.assertEqual(myStop.stop_range_ft,1000,'stop_range_ft was not set correctly');
            testCase.assertEqual(myStop.stop_altitude_ft,5000,'stop_altitude_ft was not set correctly');
        end
        function testStopConditions(testCase)
            % Instantiate StopConditions object
            myStop = StopConditions('');
            %Set stopping range and altitude. 
            myStop.stop_range_ft = 1000;
            myStop.stop_altitude_ft = 5000;
            myStop.prepareSim;

            % Run unit test simulation
            [ ~, ~, y ] = sim( 'StopConditions_UnitTest' );
            
            %North position when stop signal is sent
            north2_stop = y(end,1);
            
            %Time when stop signal is sent
            t_stop = y(end,2);
            
            %Expected values
            stop_pos = -1001;
            stop_time = 2101;
            
            %Check if simulation results match expected values.
            testCase.assertEqual(t_stop, stop_time, 'testStopConditions unit test failed. (t_stop not equal to expected value)');
            testCase.assertEqual(north2_stop, stop_pos, 'testStopConditions unit test failed. (north2_stop not equal to expected value)');       
        end        
    end
end