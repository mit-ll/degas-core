classdef unitTest_STS < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_SIMPLETRACKEDSURVEILLANCE Unit test for the SimpleTrackedSurveillance block
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the SimpleTrackedSurveillance block
    
    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;
            
            % Switch to the current directory
            simDir = which('unitTestSTS.slx');
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
            mySTS = SimpleTrackedSurveillance('ac1_ac2_');
            mySTS.prepareSim();
            testCase.assertEqual(mySTS.tunableParameterPrefix,'ac1_ac2_',...
                'SimpleTrackedSurveillance did not initialize correctly.');
        end
        function testProperties(testCase)
            mySTS = SimpleTrackedSurveillance('ac1_ac2_');
            mySTS.prepareSim();
            
            mySTS.horizontal_position_bias_stddev_ft = 5;
            mySTS.horizontal_position_jitter_stddev_ft = 0;
            
            mySTS.vertical_position_bias_stddev_ft = 5;
            mySTS.vertical_position_bias_halfwidth_ft = 100;
            mySTS.vertical_position_jitter_stddev_ft = 15;
            
            mySTS.horizontal_velocity_bias_stddev_fps = 1.5;
            mySTS.horizontal_velocity_jitter_stddev_fps = 1.5;
            
            mySTS.vertical_velocity_bias_stddev_fps = 2.5;
            mySTS.vertical_velocity_jitter_stddev_fps = 2.5;
            
            testCase.assertEqual(mySTS.horizontal_position_bias_stddev_ft, 5, "horizontal_position_bias_stddev_ft was not set properly");
            testCase.assertEqual(mySTS.horizontal_position_jitter_stddev_ft, 0, "horizontal_position_jitter_stddev_ft was not set properly");
            
            testCase.assertEqual(mySTS.vertical_position_bias_stddev_ft, 5, "vertical_position_bias_stddev_ft was not set properly");
            testCase.assertEqual(mySTS.vertical_position_bias_halfwidth_ft, 100, "vertical_position_bias_halfwidth_ft was not set properly");
            testCase.assertEqual(mySTS.vertical_position_jitter_stddev_ft, 15, "vertical_position_jitter_stddev_ft was not set properly");
            
            testCase.assertEqual(mySTS.horizontal_velocity_bias_stddev_fps, 1.5, "horizontal_velocity_bias_stddev_fps was not set properly");
            testCase.assertEqual(mySTS.horizontal_velocity_jitter_stddev_fps, 1.5, "horizontal_velocity_jitter_stddev_fps was not set properly");
            
            testCase.assertEqual(mySTS.vertical_velocity_bias_stddev_fps, 2.5, "vertical_velocity_bias_stddev_fps was not set properly");
            testCase.assertEqual(mySTS.vertical_velocity_jitter_stddev_fps, 2.5, "vertical_velocity_jitter_stddev_fps was not set properly");
        end
        function testSTS(testCase)
            %Allows users to customize figure options (displaying, saving, etc...)            
            if exist([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'file')
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'plotFig_STS');
                if exist('plotFig_STS','var')
                    display = plotFig_STS;
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
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'saveFig_STS');
                if exist('saveFig_STS','var')
                    save_ = saveFig_STS;
                else
                    save_ = false;
                end
            else
                save_ = false;
            end
            
            bad = BasicAircraftDynamics('ac1dyn_');
            bad.prepareSim();
            
            mySTS = SimpleTrackedSurveillance('ac1_ac2_');
            mySTS.prepareSim();
            
            results = sim('unitTestSTS','StopTime', num2str(1000)); 
        
            %Change scale for plots or bins for histograms
            yscalev = 250; nbins = 50;
            
            %%
            %Position Error
            e_err = results.aircraftEstimate.enuStateEstimate.e_ft.Data - results.aircraftState.e_ft.Data;
            n_err = results.aircraftEstimate.enuStateEstimate.n_ft.Data - results.aircraftState.n_ft.Data;
            h_err = results.aircraftEstimate.enuStateEstimate.h_ft.Data - results.aircraftState.h_ft.Data;
            
            %Standard deviation is zero by default
            testCase.assertLessThan(std(e_err), 1e-10, 'SimpleTrackedSurveillance Unit Test failed. (e_err is greater than tolerance)');
            testCase.assertLessThan(std(n_err), 1e-10, 'SimpleTrackedSurveillance Unit Test failed. (n_err is greater than tolerance)');
            
            %Tests to ensure the vertical error is normally distributed with the
            %specified standard deviation
            figure('name','Simple Tracked Surveillance');
            title('Vertical Error');
            xlabel('Time (s)');
            ylabel('Error (ft)');
            result = makeErrCheckHist(h_err, mean(h_err), mySTS.vertical_position_jitter_stddev_ft, yscalev, nbins);
            testCase.assertEqual(result, 1, 'SimpleTrackedSurveillance Unit Test Failed. (altitude standard deviation exceeded tolerance)');
 
            if save_
                savefig('VerticalPos.fig');
            end
            
            %%
            %Velocity Error
            edot_err = results.aircraftEstimate.enuStateEstimate.de_ftps.Data - results.aircraftState.v_ftps.Data;
            hdot_err = results.aircraftEstimate.enuStateEstimate.dh_ftps.Data - results.aircraftState.dh_ftps.Data;
            
            %Tests to ensure the horizontal rate error is normally distributed with the
            %specified standard deviation
            figure('name','Simple Tracked Surveillance');
            title('Horizontal Rate Error');
            xlabel('Time (s)');
            ylabel('Error (ftps)');
            result = makeErrCheckHist(edot_err, mean(edot_err), mySTS.horizontal_velocity_jitter_stddev_fps, yscalev, nbins);
            testCase.assertEqual(result, 1, 'SimpleTrackedSurveillance Unit Test Failed. (velocity rate standard deviation exceeded tolerance)');

            if save_
                savefig('HorizontalRate.fig');
            end
            
            %Tests to ensure the vertical rate error is normally distributed with the
            %specified standard deviation
            figure('name','Simple Tracked Surveillance');
            title('Vertical Rate Error');
            xlabel('Time (s)');
            ylabel('Error (ftps)');
            result = makeErrCheckHist(hdot_err, mean(hdot_err), mySTS.vertical_velocity_jitter_stddev_fps, yscalev, nbins);
            testCase.assertEqual(result, 1, 'SimpleTrackedSurveillance Unit Test Failed. (altitude rate standard deviation exceeded tolerance)');
            
            if save_
                savefig('VerticalRate.fig');
            end
            
            if save_
                if ~exist('sts_figures', 'dir')
                    mkdir sts_figures;
                end
                
                movefile *.fig sts_figures;
            end
        end        
    end
end