classdef unitTest_TrackedRadar_SC228 < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_TrackedRadar_SC228 Unit test for the TrackedRadar_SC228 block
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the TrackedRadar_SC228 block

    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;

            % Switch to the current directory
            simDir = which('SC228_TrackedRadarModelUnitTest.slx');
            [simDir,~,~] = fileparts(simDir);
            cd(simDir);

            % Populate base workspace with bus_definitions
            bus_definitions();
        end
    end

    methods (Test)
        function testConstructor(testCase)
            myRDR = SC228_TrackedRadarModel('uas_rdr_trckd_');
            testCase.assertEqual(myRDR.tunableParameterPrefix,'uas_rdr_trckd_',...
                'Tracked Radar did not initialize correctly.');
        end
        function testProperties(testCase)
            myRDR = SC228_TrackedRadarModel('uas_rdr_trckd_');
            myRDR.az_stddev_ft = 250; 
            myRDR.az_bias_ft = 0;
            myRDR.el_stddev_ft = 0;
            myRDR.el_bias_ft = 150;
            myRDR.azdot_stddev_ftps = 0;
            myRDR.azdot_bias_ftps = 50*DEGAS.kt2ftps;
            myRDR.azdot_tau_s = 0;
            myRDR.eldot_stddev_ftps = 800/DEGAS.min2sec;
            myRDR.eldot_bias_ftps = 0;
            myRDR.eldot_tau_s =  0;

            testCase.assertEqual(myRDR.az_stddev_ft, 250,'az_stddev_ft was not set correctly');
            testCase.assertEqual(myRDR.az_bias_ft, 0, 'az_bias_ft was not set correctly');
            
            testCase.assertEqual(myRDR.el_stddev_ft,0, 'el_stddev_ft was not set correctly');
            testCase.assertEqual(myRDR.el_bias_ft, 150, 'el_bias_ft was not set correctly');
            
            testCase.assertEqual(myRDR.azdot_stddev_ftps, 0, 'azdot_stddev_ftps was not set correctly');
            testCase.assertEqual(myRDR.azdot_bias_ftps, 50*DEGAS.kt2ftps, 'azdot_bias_ftps was not set correctly');
            testCase.assertEqual(myRDR.azdot_tau_s, 0, 'azdot_tau_s was not set correctly');
            
            testCase.assertEqual(myRDR.eldot_stddev_ftps, 800/DEGAS.min2sec, 'eldot_stddev_ftps was not set correctly');
            testCase.assertEqual(myRDR.eldot_bias_ftps,0, 'eldot_bias_ftps was not set correctly');
            testCase.assertEqual(myRDR.eldot_tau_s, 0, 'eldot_tau_s was not set correctly');
        end
        function testTrackedRadar(testCase)
         %Allows users to customize figure options (displaying, saving, etc...)            
            if exist([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'file')
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'plotFig_RDR');
                if exist('plotFig_RDR','var')
                    display = plotFig_RDR;
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
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'saveFig_RDR');
                if exist('saveFig_RDR','var')
                    save_ = saveFig_RDR;
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
            
            adsb = SC228_RadarModel('uas_rdr_');
            adsb.prepareProperties();
            adsb.prepareSim();
            
            test = SC228_TrackedRadarModel('uas_rdr_trckd_');
            test.prepareProperties();
            test.prepareSim();
            
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
            
            rdr_results = sim('SC228_TrackedRadarModelUnitTest.slx', 'StopTime', num2str(st));

            %%
            %Parse out only the valid values
            valid = rdr_results.isValid.Data;
            idx = find(valid);

            true_range = rdr_results.trueRAE.range.Data(idx);

            true_az = rdr_results.trueRAE.az.Data(idx);
            true_el = rdr_results.trueRAE.el.Data(idx);
            true_azdot = rdr_results.trueAzdot.data(idx);
            true_eldot = rdr_results.trueEldot.data(idx);

            noisy_az = rdr_results.noisyAz.Data(idx);
            noisy_el = rdr_results.noisyEl.Data(idx);
            noisy_azdot = rdr_results.noisyAzdot.Data(idx);
            noisy_eldot = rdr_results.noisyEldot.Data(idx);
            
            %Compute azimuth position and rate error to be used 
            az_err = noisy_az - true_az;
            el_err = noisy_el - true_el;
            azdot_err = noisy_azdot - true_azdot;
            eldot_err = noisy_eldot - true_eldot;
            
            %Calculate the cross-track error (XTE).Cross-track error is the horizontal component of horizontal error. 
            %With all error assumed to be horizontal, there is no range error. XTE will be calculated as
            %range*azimuth error. Vertical Error (VE) is calculated as
            %range*elevation error.
            
            XTE = true_range.*az_err;
            VE = true_range.*el_err;

            XTEdot = true_range.*azdot_err;
            VEdot = true_range.*eldot_err;

            %%
            %Parameters
            %
            yscale = 500; nbins = 50;
            
            %Horizontal Position (East)
            %Metric Threshold (95%) - 125*(x-1NM) + 250ft where x = [1NM, 6.7NM]
            mu_xte = mean(true_range)*mean(az_err);
            sigma_xte = 125*(true_range(end) - 1*DEGAS.nm2ft) + 250;

            %Vertical Position
            %Metric Threshold (95%) - 100*(x-1NM) + 150ft where x = [1NM, 6.7NM]
            mu_v = mean(true_range)*mean(el_err);
            sigma_v = 100*(true_range(end) - DEGAS.nm2ft) + 150;

            %Horizontal Rate (East)
            %Metric Threshold (95%) - 10*(x-1NM) + 50kts where x = [1NM, 6.7NM]
            mu_xtedot = mean(true_range)*mean(azdot_err);
            sigma_xtedot = 100*(true_range(end) - 1*DEGAS.nm2ft) + 50*DEGAS.kt2ftps; 

            %Vertical Rate
            %Metric Threshold (95%) - 280*(x-1NM) + 800fpm where x = [1NM, 6.7NM]
            mu_vdot = mean(true_range)*mean(eldot_err);
            sigma_vdot = 280*(true_range(end) - 1*DEGAS.nm2ft) + 800/DEGAS.min2sec; %ftps

            %%
            %Horizontal Position
            %
            figure('name','Radar');
            subplot(2,1,1);
            plot(XTE);
            title('Horizontal Position Error');
            xlabel('Time (s)');
            ylabel('Error (ft)');
            subplot(2,1,2);
            result = makeErrCheckHist(XTE, mu_xte, sigma_xte, yscale, nbins);
            
            testCase.assertEqual(result, 1, 'Radar Unit Test Failed. (Horizontal Position Error was not normally distributed)');

            if save_
                savefig('HPosError.fig');
            end

            %%
            %Vertical Position
            %
            figure('name','Radar');
            subplot(2,1,1);
            plot(XTE);
            title('Vertical Position Error');
            xlabel('Time (s)');
            ylabel('Error (ft/s)');
            subplot(2,1,2);
            result = makeErrCheckHist(VE, mu_v, sigma_v, yscale, nbins);

            testCase.assertEqual(result, 1, 'Radar Unit Test Failed. (Vertical Position Error was not normally distributed)');

            if save_
                savefig('VPosErr.fig');
            end

            %%
            % Horizontal Rate
            %
            figure('name','Radar');
            subplot(2,1,1);
            plot(XTE);
            title('Horizontal Rate Error');
            xlabel('Time (s)');
            ylabel('Error (ft)');
            subplot(2,1,2);
            result = makeErrCheckHist(XTEdot, mu_xtedot, sigma_xtedot, yscale, nbins);
            
            testCase.assertEqual(result, 1, 'Radar Unit Test Failed. (Vertical Rate Error was not normally distributed)');

            if save_
                savefig('HRateError.fig');
            end

            %%
            % Vertical Rate
            %
            figure('name','Radar');
            subplot(2,1,1);
            plot(XTE);
            title('Vertical Rate Error');
            xlabel('Time (s)');
            ylabel('Error (ft/s)');
            subplot(2,1,2);
            result = makeErrCheckHist(VEdot, mu_vdot, sigma_vdot, yscale, nbins);
            
            testCase.assertEqual(result, 1, 'Radar Unit Test Failed. (Vertical Rate Error was not normally distributed)');

            if save_
                savefig('VRateErr.fig');
            end

            if save_
                if ~exist('rdr_figures', 'dir')
                    mkdir rdr_figures;
                end
                
                movefile *.fig rdr_figures;
            end
            
            %Cleanup
            delete traj1.mat
            delete traj2.mat
        end
    end
end