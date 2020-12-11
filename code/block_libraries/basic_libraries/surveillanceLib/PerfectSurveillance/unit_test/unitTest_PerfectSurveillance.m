classdef unitTest_PerfectSurveillance < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_PERFECTSURVEILLANCE Unit test for the PerfectSurveillance block
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the PerfectSurveillance block
    
    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;
            
            % Switch to the current directory
            simDir = which('unitTestPerfectSurveillance.slx');
            [simDir,~,~] = fileparts(simDir);
            cd(simDir);
            
            % Populate base workspace with bus_definitions
            bus_definitions();
        end
    end
    
    % Test Method Block
    methods (Test)
        % Test Function
        function testPerfectSurveillance(testCase)
            bad = BasicAircraftDynamics('ac1dyn_');
            bad.prepareSim();
            
            [~,~,~] = sim('unitTestPerfectSurveillance');
            
            %Perfect surveillance assumes no noise added, thus the inputs
            %and outputs of the simulation should be the same.
            testCase.assertEqual(aircraftEstimate.latLonAltEst.lat_rad.Data,aircraftState.latLonAltState.lat_rad.Data);
            testCase.assertEqual(aircraftEstimate.latLonAltEst.lon_rad.Data,aircraftState.latLonAltState.lon_rad.Data);
            testCase.assertEqual(aircraftEstimate.latLonAltEst.alt_ft.Data,aircraftState.latLonAltState.alt_ft.Data);
            
            testCase.assertEqual(aircraftEstimate.enuStateEstimate.e_ft.Data,aircraftState.e_ft.Data);
            testCase.assertEqual(aircraftEstimate.enuStateEstimate.n_ft.Data,aircraftState.n_ft.Data);
            testCase.assertEqual(aircraftEstimate.enuStateEstimate.h_ft.Data,aircraftState.h_ft.Data);
        end        
    end
end