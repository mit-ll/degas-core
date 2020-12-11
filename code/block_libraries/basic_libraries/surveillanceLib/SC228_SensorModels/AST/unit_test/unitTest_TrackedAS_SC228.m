classdef unitTest_TrackedAS_SC228 < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_TrackedAS_SC228 Unit test for the TrackedAS_SC228 block
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the TrackedAS_SC228 block
% 
    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;

            % Switch to the current directory
            simDir = which('SC228_TrackedASModelUnitTest.slx');
            [simDir,~,~] = fileparts(simDir);
            cd(simDir);

            % Populate base workspace with bus_definitions
            bus_definitions();
        end
    end

    methods (Test)
        function testConstructor(testCase)
            myAS = SC228_TrackedActiveSurveillanceModel('uas_tcas_trckd_', 'dt_s', 0.1);
            testCase.assertEqual(myAS.tunableParameterPrefix,'uas_tcas_trckd_',...
                'Tracked Active Surveillance did not initialize correctly.');
        end
        function testProperties(testCase)
            myAS = SC228_TrackedActiveSurveillanceModel('uas_tcas_trckd_', 'dt_s', 0.1);
            myAS.psi_stddev_ft = 1000*(10000 - 0.5*DEGAS.nm2ft) + 1250;
            myAS.psi_bias_ft = 0;
            myAS.psidot_stddev_ftps = 33*(10000 - 0.5*DEGAS.nm2ft) + 85*DEGAS.kt2ftps;
            myAS.psidot_bias_ftps = 0;
            
            testCase.assertEqual(myAS.psi_stddev_ft, 1000*(10000 - 0.5*DEGAS.nm2ft) + 1250,'psi_stddev_ft was not set correctly');
            testCase.assertEqual(myAS.psi_bias_ft, 0, 'psi_bias_ft was not set correctly');
            testCase.assertEqual(myAS.psidot_stddev_ftps, 33*(10000 - 0.5*DEGAS.nm2ft) + 85*DEGAS.kt2ftps, 'psidot_stddev_ftps was not set correctly');
            testCase.assertEqual(myAS.psidot_bias_ftps, 0, 'psidot_bias_ftps was not set correctly');
        end
        function testTrackedAS(testCase)
            %Allows users to customize figure options (displaying, saving, etc...)            
            if exist([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'file')
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'plotFig_AST');
                if exist('plotFig_AST','var')
                    display = plotFig_AST;
                else
                    display = false;
                end
                if (display)
                    set(0, 'DefaultFigureVisible', 'on');
                else
                    set(0, 'DefaultFigureVisible', 'off');
                end
            else
                set(0, 'DefaultFigureVisible', 'off');
            end
            
            if exist([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'file')
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'saveFig_AST');
                if exist('saveFig_AST','var')
                    save_ = saveFig_AST;
                else
                    save_ = false;
                end
            else
                save_ = false;
            end
            
            ac1 = BasicAircraftDynamics('ac1dyn_');
            ac1.prepareSim();
            ac2 = BasicAircraftDynamics('ac2dyn_');
            ac2.prepareSim();
            
            s = SC228_TrackedActiveSurveillanceModel('uas_tcas_trckd_', 'dt_s', 0.1);
            s.prepareProperties();
            s.prepareSim();
            
            %Load the sample trajectories
            traj1 = load([getenv('DEGAS_HOME'), filesep, 'block_libraries', filesep, 'basic_libraries'...
                , filesep, 'unitTestUtilities', filesep, 'trajectories', filesep, 'traj1.mat']);
            traj1 = traj1.traj1;
            
            save traj1 traj1
            
            traj2 = load([getenv('DEGAS_HOME'), filesep, 'block_libraries', filesep, 'basic_libraries'...
                , filesep, 'unitTestUtilities', filesep, 'trajectories', filesep, 'traj2.mat']);
            traj2 = traj2.traj2;
            
            save traj2 traj2

            %Stop time
            st = 10000;
            
            TCAS_results = sim('SC228_TrackedASModelUnitTest.slx','StopTime', num2str(st));

            %Parse out the valid values
            valid = TCAS_results.tcas_valid2.Data;
            idx = find(valid);
            
            %Bearing and bearing rate error
            psi_err = TCAS_results.noisyPsi.Data(idx) - TCAS_results.psi.Data(idx);
            psidot_err = TCAS_results.noisyPsidot.Data(idx) - TCAS_results.psidot.Data(idx);

            %Calculate the cross-track error (XTE). Cross-track error is the horizontal component of horizontal error. 
            %With all error assumed to be horizontal, there is no range error. XTE will be calculated as
            %range*bearing_error
            XTE = TCAS_results.trueRange.Data(idx).*(psi_err);
            XTEdot = TCAS_results.trueRange.Data(idx).*(psidot_err);
            
            %%
            %Parameters
            %
            yscale = 150; nbins = 75;

            %Assuming constant range + no range error. Determine ship distance from
            %trajectories.
            true_range = TCAS_results.trueRange.Data(1);

            %Horizontal Position 
            %Metric Threshold (95%) - 1000*(x-0.5NM) + 1250ft where x = [0.5NM, 14NM]
            mu_h = mean(true_range)*mean(psi_err);
            sigma_h = 1000*(true_range - 0.5*DEGAS.nm2ft) + 1250;

            %Horizontal Rate
            %Metric Threshold (95%) - 33*(x-0.5NM) + 85kts where x = [0.5NM, 14NM]
            mu_hdot = mean(true_range)*mean(psidot_err);
            sigma_hdot = 33*(true_range - 0.5*DEGAS.nm2ft) + 85*DEGAS.kt2ftps;

            %%
            %Horizontal Position
            %
            figure('name','Active Surveillance');
            subplot(2,1,1);
            plot(XTE);
            title('Horizontal Position Error');
            xlabel('Time (s)');
            ylabel('Error (ft)');
            subplot(2,1,2);
            result = makeErrCheckHist(XTE, mu_h, sigma_h, yscale, nbins);
            
            testCase.assertEqual(result, 1, 'Active Surveillance Unit Test Failed. (Horizontal Position Error was not normally distributed)');

            if save_
                savefig('PosError.fig');
            end

            %%
            %Horizontal Velocity
            %
            figure('name','Active Surveillance');
            subplot(2,1,1);
            plot(XTEdot);
            title('Horizontal Rate Error');
            xlabel('Time (s)');
            ylabel('Error (ft/s)');
            subplot(2,1,2);
            result = makeErrCheckHist(XTEdot, mu_hdot, sigma_hdot, yscale, nbins);
            
            testCase.assertEqual(result, 1, 'Active Surveillance Unit Test Failed. (Horizontal Rate Error was not normally distributed)');

            if save_
                savefig('RateError.fig');
            end

            %%
            %Vertical Position
            %TCAS altitude is only quantized. Assumed that no error is added.
            % 
            testCase.assertEqual(TCAS_results.degradedAlt.Data,...
                max(0,TCAS_results.trueAlt.Data + TCAS_results.altBias.Data),...
                'TCAS Unit Test failed. (Altitude improperly quantized)');

            if save_
                if ~exist('tcas_figures', 'dir')
                    mkdir tcas_figures;
                end
                
                movefile *.fig tcas_figures;
            end
            
            %Cleanup
            delete traj1.mat
            delete traj2.mat
        end
    end
end