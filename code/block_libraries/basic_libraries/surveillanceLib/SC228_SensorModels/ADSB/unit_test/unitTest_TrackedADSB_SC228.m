classdef unitTest_TrackedADSB_SC228 < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_TrackedADSB_SC228 Unit test for the TrackedADSB_SC228 block
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the TrackedADSB_SC228 block
% 
    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;

            % Switch to the current directory
            simDir = which('SC228_TrackedADSBModelUnitTest.slx');
            [simDir,~,~] = fileparts(simDir);
            cd(simDir);

            % Populate base workspace with bus_definitions
            bus_definitions();
        end
    end

    methods (Test)
        function testConstructor(testCase)
            myADSB = SC228_TrackedAdsbModel('uas_adsb_trckd_');
            testCase.assertEqual(myADSB.tunableParameterPrefix,'uas_adsb_trckd_',...
                'Tracked ADSB did not initialize correctly.');
        end
        function testProperties(testCase)
            myADSB = SC228_TrackedAdsbModel('uas_adsb_trckd_');
            myADSB.N_stddev_ft = 900; 
            myADSB.E_stddev_ft = 900;
            myADSB.Ndot_stddev_ftps = 30*DEGAS.kt2ftps;
            myADSB.Edot_stddev_ftps = 30*DEGAS.kt2ftps;
            
            testCase.assertEqual(myADSB.N_stddev_ft, 900,'N_stddev_ft was not set correctly');
            testCase.assertEqual(myADSB.E_stddev_ft, 900, 'E_stddev_ft was not set correctly');
            testCase.assertEqual(myADSB.Ndot_stddev_ftps,30*DEGAS.kt2ftps, 'Ndot_stddev_ftps was not set correctly');
            testCase.assertEqual(myADSB.Edot_stddev_ftps, 30*DEGAS.kt2ftps, 'Edot_stddev_ftps was not set correctly');
        end
        function testTrackedADSB(testCase)
            %Allows users to customize figure options (displaying, saving, etc...)            
            if exist([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'file')
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'plotFig_ADSB');
                if exist('plotFig_ADSB','var')
                    display = plotFig_ADSB;
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
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'saveFig_ADSB');
                if exist('saveFig_ADSB','var')
                    save_ = saveFig_ADSB;
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
            
            adsb = SC228_TrackedAdsbModel('uas_adsb_trckd_');
            adsb.prepareProperties();
            adsb.prepareSim();
            
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
            
            adsb_results = sim('SC228_TrackedADSBModelUnitTest.slx', 'StopTime', num2str(st));

            %Position error
            e_err = adsb_results.aircraftEstimateADSB.enuStateEstimate.e_ft.Data - adsb_results.trueStatesADSB.e_ft.Data;
            %Rate error
            edot_err = adsb_results.aircraftEstimateADSB.enuStateEstimate.de_ftps.Data - adsb_results.trueStatesADSB.Edot_ftps.Data;
            hdot_err = adsb_results.aircraftEstimateADSB.enuStateEstimate.dh_ftps.Data - adsb_results.trueStatesADSB.hdot_ftps.Data;

            %%
            %Parse out only the valid values
            valid = adsb_results.aircraftEstimateADSB.isValid.Data;
            idx = find(valid);

            %%
            %Parameters
            %
            yscale = 250; nbins = 50;

            %Horizontal Position
            mu_e = mean(e_err(idx));
            sigma_e = 900;

            %Horizontal Rate
            mu_edot = mean(edot_err(idx));
            sigma_edot = 30*DEGAS.kt2ftps;

            %Vertical Position
            mu_h = 0;
            sigma_h = 300;

            %Vertical Rate
            mu_hdot = 0;
            sigma_hdot = 400/DEGAS.min2sec; %fpm -> fps

            %%
            %Horizontal Position
            %Assuming both aircraft are traveling due north with constant range - XTE
            %therefore is only in the east direction
            %
            figure('name','ADSB');
            subplot(2,1,1);
            plot(e_err(idx));
            title('Horizontal Position Error');
            xlabel('Time (s)');
            ylabel('Error (ft)');
            subplot(2,1,2);
            result = makeErrCheckHist(e_err(idx), mu_e, sigma_e, yscale, nbins);
            
            testCase.assertEqual(result, 1, 'ADSB Unit Test Failed. (Horizontal Position Error was not normally distributed)');

            if save_
                savefig('PosError.fig');
            end

            %%
            %Horizontal Velocity
            %
            figure('name','ADSB');
            subplot(2,1,1);
            plot(edot_err(idx));
            title('Horizontal Rate Error');
            xlabel('Time (s)');
            ylabel('Error (ft/s)');
            subplot(2,1,2);
            result = makeErrCheckHist(edot_err(idx), mu_edot, sigma_edot, yscale, nbins);
            
            testCase.assertEqual(result, 1, 'ADSB Unit Test Failed. (Horizontal Velocity Error was not normally distributed)');

            if save_
                savefig('RateError.fig');
            end

            %%
            %Vertical Position
            %Only check for quantization
            %
            testCase.assertEqual(adsb_results.int_adsb_degradedAlt.Data,...
                max(0,adsb_results.int_adsb_trueAlt.Data + adsb_results.int_adsb_altBias.Data),...
                'ADSB Unit Test failed. (Altitude improperly quantized)');
            
            %%
            %Vertical Velocity
            %Error is drawn from a laplacian distribution
            %
            figure('name','ADSB');
            subplot(2,1,1);
            plot(hdot_err(idx));
            title('Vertical Rate Error');
            xlabel('Time (s)');
            ylabel('Error (ft/s)');
            subplot(2,1,2);
            result = laplaceCheck(hdot_err(idx), mu_hdot, 5.6, yscale, nbins); 
            
            testCase.assertEqual(result, 1, 'ADSB Unit Test Failed. (Vertical Velocity Error was not Laplacian)');

            if save_
                if ~exist('adsb_figures', 'dir')
                    mkdir adsb_figures;
                end
                
                movefile *.fig adsb_figures;
            end
            
            %Cleanup
            delete traj1.mat
            delete traj2.mat
        end
    end
end