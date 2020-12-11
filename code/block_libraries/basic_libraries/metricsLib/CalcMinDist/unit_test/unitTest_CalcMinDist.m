classdef unitTest_CalcMinDist < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_CalcMinDist Unit test for the CalcMinDist block
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the CalcMinDist block
    
    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;
            
            % Switch to the current directory
            simDir = which('unitTestCalcMinDist.slx');
            [simDir,~,~] = fileparts(simDir);
            cd(simDir);
            
            % Populate base workspace with bus_definitions
            bus_definitions();
        end
    end
    
    % Test Method Block
    methods (Test)
        % Test Function
        function testCalcMinDist(testCase)
            ac1 = BasicAircraftDynamics('ac1dyn_');
            ac1.prepareSim();
            ac2 = BasicAircraftDynamics('ac2dyn_');
            ac2.prepareSim();
            
            folderID = [getenv('DEGAS_HOME') filesep 'block_libraries' filesep 'basic_libraries'...
                filesep 'unitTestUtilities' filesep 'Encounters'];
            
            events = open([folderID filesep 'unitTestEncounters.mat']);
            
            event1 = events.samples(1).updates(1).event';
            event2 = events.samples(1).updates(2).event';
            save event1 event1
            save event2 event2
            
            [~,~,~] = sim('unitTestCalcMinDist.slx');
            
            %Calculate separation for 100 time steps in an encounter
            for i = 1:100
                v_sep(i) = norm(OwnState.h_ft.Data(i) - IntState.h_ft.Data(i));
                he_sep(i) = norm(OwnState.e_ft.Data(i) - IntState.e_ft.Data(i));
                hn_sep(i) =  norm(OwnState.n_ft.Data(i) - IntState.n_ft.Data(i));
            end
            
            %Compute horizontal separation with north/east components
            h_sep = sqrt(he_sep.^2 + hn_sep.^2);
            
            %Check to ensure simulation produces correct results compared
            %to the manual calculations
            testCase.assertEqual(v_sep', vsep.Data(2:end), "CalcMinDist Unit Test failed (vertical separation was not computed correctly)");
            testCase.assertEqual(h_sep', hsep.Data(2:end), "CalcMinDist Unit Test failed (horizontal separation was not computer correctly)");
            
            %Cleanup
            delete event1.mat
            delete event2.mat
        end        
    end
end