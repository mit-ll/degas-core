classdef unitTest_EOIR < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_EOIR Unit test for the EOIR block
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the EOIR block
    
    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;
            
            % Switch to the current directory
            simDir = which('unitTestEOIR.slx');
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
            myEOIR = EOIRParametricModel('ac1IntEOIR_');
            testCase.assertEqual(myEOIR.tunableParameterPrefix,'ac1IntEOIR_',...
                'EOIRParametricModel did not initialize correctly.');
        end
        function testParameters(testCase)
            myEOIR = EOIRParametricModel('ac1IntEOIR_');
            
            testCase.assertEqual(myEOIR.dt_s, 0.1, "dt_s was not set properly");
            testCase.assertEqual(myEOIR.range_clrd_noise_flag, 1, "range_clrd_noise_flag was not set properly");
            
            testCase.assertEqual(myEOIR.az_random_stddev_rad, 1.0e-3, "az_random_stddev_rad was not set properly");
            testCase.assertEqual(myEOIR.az_tau_s, 0, "az_tau_s was not set properly");
            testCase.assertEqual(myEOIR.az_bias_stddev_rad, 0, "az_bias_stddev_rad was not set properly");
            
            testCase.assertEqual(myEOIR.el_random_stddev_rad, 1.0e-3, "el_random_stddev_rad was not set properly");
            testCase.assertEqual(myEOIR.el_tau_s, 0, "el_tau_s was not set properly");
            testCase.assertEqual(myEOIR.el_bias_stddev_rad, 0, "el_bias_stddev_rad was not set properly");
           
            testCase.assertEqual(myEOIR.azdot_random_stddev_radps, 1.4e-3, "azdot_random_stddev_radps was not set properly");
            testCase.assertEqual(myEOIR.azdot_tau_s, 0, "azdot_tau_s was not set properly");
            testCase.assertEqual(myEOIR.azdot_bias_stddev_radps, 0, "azdot_bias_stddev_radps was not set properly");
            
            testCase.assertEqual(myEOIR.eldot_random_stddev_radps, 1.4e-3, "eldot_random_stddev_radps was not set properly");
            testCase.assertEqual(myEOIR.eldot_tau_s, 0, "eldot_tau_s was not set properly");
            testCase.assertEqual(myEOIR.eldot_bias_stddev_radps, 0, "eldot_bias_stddev_radps was not set properly");
            
            testCase.assertEqual(myEOIR.rng_random_stddev_ft, 15.24*DEGAS.m2ft, "rng_random_stddev_ft was not set properly");
            testCase.assertEqual(myEOIR.rng_tau_s, 5, "rng_tau_s was not set properly");
            testCase.assertEqual(myEOIR.rng_bias_stddev_ft, 0, "rng_bias_stddev_ft was not set properly")
            testCase.assertEqual(myEOIR.rng_bias_switch, 0, "rng_bias_switch was not set properly");
            testCase.assertEqual(myEOIR.rng_std_dev_gain, 0.03, "rng_std_dev_gain was not set properly");
            
            testCase.assertEqual(myEOIR.rngdot_random_stddev_ftps, 3.6576*DEGAS.m2ft, "rngdot_random_stddev_ftps was not set properly");
            testCase.assertEqual(myEOIR.rngdot_tau_s, 2, "rngdot_tau_s was not set properly");
            testCase.assertEqual(myEOIR.rngdot_bias_stddev_ftps, 0, "rngdot_bias_stddev_ftps was not set properly");
            testCase.assertEqual(myEOIR.rngdot_std_dev_gain, 0.05, "rngdot_std_dev_gain was not set properly");
            testCase.assertEqual(myEOIR.rngdot_delay_s, 5, "rngdot_delay_s was not set properly");
            
            testCase.assertEqual(myEOIR.sns_max_range_ft, 2.5*DEGAS.nm2ft, "sns_max_range_ft was not set properly");
            testCase.assertEqual(myEOIR.sns_for_azimuth_deg, Inf, "sns_for_azimuth_deg was not set properly");
            testCase.assertEqual(myEOIR.sns_for_elevation_deg, Inf, "sns_for_elevation_deg was not set properly");           
        end
        function testEOIR(testCase)
            %Allows users to customize figure options (displaying, saving, etc...)            
            if exist([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'file')
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'plotFig_EOIR');
                if exist('plotFig_EOIR','var')
                    display = plotFig_EOIR;
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
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'saveFig_EOIR');
                if exist('saveFig_EOIR','var')
                    save_ = saveFig_EOIR;
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
            
            myEOIR = EOIRParametricModel('ac1IntEOIR_');
            myEOIR.range_clrd_noise_flag = 0;
            myEOIR.prepareSim();
            
            if ~exist('eoir_traj', 'dir')
               mkdir eoir_traj;
            end

            if ~isempty(dir('traj*.mat'))
                delete traj*.mat
            end
            
            %Stop time
            st = 5000;
            results = sim('unitTestEOIR.slx','StopTime', num2str(st));
            
            %%
            %Change scale for plots or bins for histograms
            yscalev = 500; nbins = 50;

            %% 
            %   Bearing and Elevation Error:
            %   - Angle measurement error is modeled by Gaussian white noise
            %   - sigma < 1 mrad
            %   - Measurements are not time corrected.
            %

            %Azimuth
            az_noisy = results.EOIR_states.az_noisy.Data;
            az_true = results.true_states.az.Data;
            az_err = az_noisy - az_true;

            figure('name','EOIR');
            subplot(2,1,1);
            plot(az_err, 'r');
            title('Azimuth Error');
            xlabel('Time (s)');
            ylabel('Azimuth (Rad)');

            subplot(2,1,2);
            result = makeErrCheckHist(az_err, mean(az_err), myEOIR.az_random_stddev_rad, yscalev, nbins);
            
            testCase.assertEqual(result, 1, 'EOIR Unit Test Failed. (azimuth error standard deviation exceeded tolerance)');

            if save_
                savefig('AzimuthError.fig');
            end

            %Elevation
            el_noisy = results.EOIR_states.el_noisy.Data;
            el_true = results.true_states.el.Data;
            el_err = el_noisy - el_true;

            figure('name','EOIR');
            subplot(2,1,1);
            plot(el_err, 'b');
            title('Elevation Error');
            xlabel('Time (s)');
            ylabel('Elevation (Rad)');

            subplot(2,1,2);
            result = makeErrCheckHist(el_err, mean(el_err), myEOIR.el_random_stddev_rad, yscalev, nbins);
            
            testCase.assertEqual(result, 1, 'EOIR Unit Test Failed. (elevation error standard deviation exceeded tolerance)');

            if save_
                savefig('ElevationError.fig')    
            end
            
            %%
            %   Bearing and Elevation Rate Error:
            %   - Angular rates error is modeled by Gaussian white noise
            %   - sigma < 1.4 mrad/s
            %   - Temporal correction decay time is about 10 samples
            %

            %Azimuth Rate
            az_dot_noisy = results.EOIR_states.azdot_rps.Data;
            az_dot_true = results.true_states.azdot.Data;
            az_dot_err = az_dot_noisy - az_dot_true;

            figure('name','EOIR');
            subplot(2,1,1);
            plot(az_dot_err, 'r');
            title('Azimuth Rate Error');
            xlabel('Time (s)');
            ylabel('Azimuth (Rad/s)');

            subplot(2,1,2);
            result = makeErrCheckHist(az_dot_err, mean(az_dot_err), myEOIR.azdot_random_stddev_radps, yscalev, nbins);
            
            testCase.assertEqual(result, 1, 'EOIR Unit Test Failed. (azimuth rate error standard deviation exceeded tolerance)');

            if save_
                savefig('AzimuthRateError.fig');
            end

            %Elevation Rate
            el_dot_noisy = results.EOIR_states.eldot_rps.Data;
            el_dot_true = results.true_states.eldot.Data;
            el_dot_err = el_dot_noisy - el_dot_true;

            figure('name','EOIR');
            subplot(2,1,1);
            plot(el_dot_err, 'g');
            title('Elevation Rate Error');
            xlabel('Time (s)');
            ylabel('Elevation Rate (Rad/s)');

            subplot(2,1,2);
            result = makeErrCheckHist(el_dot_err, mean(el_dot_err), myEOIR.eldot_random_stddev_radps, yscalev, nbins);
            
            testCase.assertEqual(result, 1, 'EOIR Unit Test Failed. (elevation rate error standard deviation exceeded tolerance)');

            if save_
                savefig('ElevRateError.fig')
            end
            
            %%
            %   Range Estimation:
            %   - Range estimation error is intruder and range dependent
            %   - eps(R) = mu(R) + sigma(R)*randn(1)
            %   - Time correlation is TBD
            %
            
            true_range = results.true_states.range.Data;
            noisy_range = results.EOIR_states.range.Data;
            range_error = noisy_range - true_range;
            
            figure('name','EOIR');
            subplot(2,1,1);
            plot(range_error);
            title('Range Error');
            xlabel('Time (s)');
            ylabel('Range (ft)');
            
            range_mu = max(0.03*true_range);

            subplot(2,1,2);
            result = makeErrCheckHist(range_error, mean(range_error), range_mu, yscalev, nbins);
            
            testCase.assertEqual(result, 1, 'EOIR Unit Test Failed. (range standard deviation exceeded tolerance)');

            if save_
                savefig('RangeError.fig');
            end
      
            %%
            %Use different trajectories for the range rate.
            %This must be done because constant range means range rate is zero.
            copyfile eoir_traj/traj1_RR.mat .
            copyfile eoir_traj/traj2_RR.mat .
 
            movefile traj1_RR.mat traj1.mat
            movefile traj2_RR.mat traj2.mat
            
            %%
            %Run the simulation again with new trajectories   
            results = sim('unitTestEOIR.slx','StopTime', num2str(5000)); 

            %%
            %   Range Rate Estimation:
            %   - Range rate estimation error is 5% at 1 sigma of true range rate
            %   - Delay is 5s (the time needed to provide the information first
            %     detection
            %

            true_range_rate = results.true_states.rdot.Data;
            noisy_range_rate = results.EOIR_states.rdot_ftps.Data;
            range_rate_err =  noisy_range_rate - true_range_rate;
            
            range_rate_mu = max(myEOIR.rngdot_std_dev_gain*true_range_rate);

            figure('name','EOIR');
            subplot(2,1,1)
            plot(range_rate_err, 'k');
            title('Range Rate Estimation Total Error');
            xlabel('Time (s)');
            ylabel('Range Rate Error (ft/s)');

            subplot(2,1,2);
            result = makeErrCheckHist(range_rate_err, mean(range_rate_err), range_rate_mu, yscalev, nbins);
            
            testCase.assertEqual(result, 1, 'EOIR Unit Test Failed. (range rate standard deviation exceeded tolerance)');

            if save_
                savefig('RangeRateError.fig');
            end

            if save_
                if ~exist('eoir_figures', 'dir')
                    mkdir eoir_figures;
                end
                
                movefile *.fig eoir_figures;
            end
            
            %Cleanup
            delete traj1.mat
            delete traj2.mat
        end        
    end
end