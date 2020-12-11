classdef unitTest_CommonMetrics < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_CommonMetrics Unit test for the CommonMetrics block 
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the CommonMetrics block

    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;
            
            % Switch to the current directory
            simDir = which('commonMetricsValidationSim.slx');
            [simDir,~,~] = fileparts(simDir);
            cd(simDir);
            
            % Populate base workspace with bus_definitions
            bus_definitions();
        end
    end
    
    % Test Method Block
    methods (Test)
        % Compute the common metrics (HMD, VMD, TCA, NMAC) from an
        % encounter using the Common Metrics block, and compare to manually
        % calculated values.
        function testCommonMetrics(testCase)        
            ac1dyn = BasicAircraftDynamics('ac1dyn_');
            ac1dyn.prepareSim();
            ac2dyn = BasicAircraftDynamics('ac2dyn_');
            ac2dyn.prepareSim();

            folderID = [getenv('DEGAS_HOME') filesep 'block_libraries' filesep 'basic_libraries'...
                filesep 'unitTestUtilities' filesep 'Encounters'];
            
            events = open([folderID filesep 'unitTestEncounters.mat']);
            metaData = open([folderID filesep 'metaData.mat']);

            %Obtain event data from encounter
            event1 = events.samples(1).updates(1).event';
            assignin('base', 'event1', event1);
            delete('event1.mat');
            save event1 event1

            event2 = events.samples(1).updates(2).event';
            assignin('base', 'event2', event2);
            delete('event2.mat');
            save event2 event2

            % Initial Conditions
            ac1dyn.v_ftps = events.samples(1).v_ftps(1);
            ac1dyn.N_ft = events.samples(1).n_ft(1);
            ac1dyn.E_ft = events.samples(1).e_ft(1);
            ac1dyn.h_ft = events.samples(1).h_ft(1);
            ac1dyn.psi_rad = events.samples(1).heading_rad(1);
            ac1dyn.theta_rad = events.samples(1).pitch_rad(1);
            ac1dyn.phi_rad = events.samples(1).bank_rad(1);
            ac1dyn.a_ftpss = events.samples(1).a_ftpss(1);

            assignin('base','ac1dyn_v_ftps',ac1dyn.v_ftps);
            assignin('base','ac1dyn_N_ft',ac1dyn.N_ft);
            assignin('base','ac1dyn_E_ft',ac1dyn.E_ft);
            assignin('base','ac1dyn_h_ft',ac1dyn.h_ft);
            assignin('base','ac1dyn_psi_rad',ac1dyn.psi_rad);
            assignin('base','ac1dyn_theta_rad',ac1dyn.theta_rad);
            assignin('base','ac1dyn_phi_rad',ac1dyn.phi_rad);
            assignin('base','ac1dyn_a_ftpss',ac1dyn.a_ftpss);

            ac2dyn.v_ftps = events.samples(1).v_ftps(2);
            ac2dyn.N_ft = events.samples(1).n_ft(2);
            ac2dyn.E_ft = events.samples(1).e_ft(2);
            ac2dyn.h_ft = events.samples(1).h_ft(2);
            ac2dyn.psi_rad = events.samples(1).heading_rad(2);
            ac2dyn.theta_rad = events.samples(1).pitch_rad(2);
            ac2dyn.phi_rad = events.samples(1).bank_rad(2);
            ac2dyn.a_ftpss = events.samples(1).a_ftpss(2);

            assignin('base','ac2dyn_v_ftps',ac2dyn.v_ftps);
            assignin('base','ac2dyn_N_ft',ac2dyn.N_ft);
            assignin('base','ac2dyn_E_ft',ac2dyn.E_ft);
            assignin('base','ac2dyn_h_ft',ac2dyn.h_ft);
            assignin('base','ac2dyn_psi_rad',ac2dyn.psi_rad);
            assignin('base','ac2dyn_theta_rad',ac2dyn.theta_rad);
            assignin('base','ac2dyn_phi_rad',ac2dyn.phi_rad);
            assignin('base','ac2dyn_a_ftpss',ac2dyn.a_ftpss);   

            % Simulate
            load_system( 'commonMetricsValidationSim' );

            [~,~,~] = sim('commonMetricsValidationSim');
            
            %Set tolerance
            tol = 1e-6;

            %Computed expected hmd and vmd
            hmd_ft_true = metaData.enc_metadata(1).hmd(1);
            vmd_ft_true = metaData.enc_metadata(1).vmd(1);

            %Find TCA
            tca_true = metaData.enc_metadata(1).tca(1)/10;

            %Determine whether NMAC has occurred
            if (hmd_ft_true < 500 && vmd_ft_true < 100)
                NMAC_true = true;
            else
                NMAC_true = false;
            end
            
            %Compare the outputs from the simulation to the truth values
            %obtained manually above. 
            testCase.assertEqual(NMAC,NMAC_true,'CommonMetrics unit test failed. (NMAC not equal to expected value)');
            testCase.assertLessThanOrEqual(abs(hmd_ft-hmd_ft_true),tol,'CommonMetrics unit test failed. (hmd_ft difference not less than expected value)' );
            testCase.assertLessThanOrEqual(abs(vmd_ft-vmd_ft_true),tol,'CommonMetrics unit test failed. (vmd_ft difference not less than expected value)' );
            testCase.assertLessThanOrEqual(abs(tca-tca_true),tol,'CommonMetrics unit test failed. (tca difference not less than expected value)');
            
            %Cleanup
            delete event1.mat
            delete event2.mat
        end        
    end
end