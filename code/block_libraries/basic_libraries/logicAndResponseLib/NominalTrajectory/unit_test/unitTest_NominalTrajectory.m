classdef unitTest_NominalTrajectory < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_NOMINALTRAJECTORY Unit test for the NominalTrajectory block
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the NominalTrajectory block
    
    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;
            
            % Switch to the current directory
            simDir = which('unitTestNominalTrajectory.slx');
            [simDir,~,~] = fileparts(simDir);
            cd(simDir);
            
            % Populate base workspace with bus_definitions
            bus_definitions();
        end
    end
    
    % Test Method Block
    methods (Test)
        % Test Function
        function testNominalTrajectory(testCase)
            
            folderID = [getenv('DEGAS_HOME') filesep 'block_libraries' filesep 'basic_libraries'...
                filesep 'unitTestUtilities' filesep 'Encounters'];
            
            events = open([folderID filesep 'unitTestEncounters.mat']);
            event1 = events.samples(1).updates(1).event';
            save event1 event1
            
            [~, ~, ~] = sim('unitTestNominalTrajectory.slx');
            
            %Esnure values obtained from event files match output of
            %aircraft commands block
            testCase.assertEqual(aircraftCommands.dh_ftps.Data(1), event1(2,1), 'NominalTrajectory Unit Test failed. (dh_ftps was not computed correctly)');
            testCase.assertEqual(aircraftCommands.dpsi_radps.Data(1), event1(3,1), 'NominalTrajectory Unit Test failed. (dpsi_radps was not computed correctly)');
            testCase.assertEqual(aircraftCommands.dv_ftps2.Data(1), event1(4,1), 'NominalTrajectory Unit Test failed. (dv_ftps2 was not computed correctly)');         
        
            %Cleanup
            delete event1.mat
        end        
    end
end