classdef unitTest_OwnshipError < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_OwnshipError Unit test for the OwnshipError block
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the OwnshipError block
    
    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;
            
            % Switch to the current directory
            simDir = which('unitTestOwnshipError.slx');
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
            myOE = OwnshipError('uas_own_');
            testCase.assertEqual(myOE.tunableParameterPrefix,'uas_own_',...
                'OwnshipError did not initialize correctly.');
        end
        function testOwnshipError(testCase)
            %Allows users to customize figure options (displaying, saving, etc...)            
            if exist([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'file')
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'plotFig_OE');
                if exist('plotFig_OE','var')
                    display = plotFig_OE;
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
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'saveFig_OE');
                if exist('saveFig_OE','var')
                    save_ = saveFig_OE;
                else
                    save_ = false;
                end
            else
                save_ = false;
            end
            
            ac1 = BasicAircraftDynamics('ac1dyn_');
            ac1.prepareSim();
            myOE = OwnshipError('uas_own_');
            myOE.prepareSim();            
            
            results = sim('unitTestOwnshipError.slx', 'stoptime', num2str(10000));
                        
            %Figure
            yscale = 500; nbins = 50;
            
            %Compute error for euler angles
            psi_err = results.noisyAircraftState.psi_rad.Data - results.aircraftState.psi_rad.Data;
            phi_err = results.noisyAircraftState.phi_rad.Data - results.aircraftState.phi_rad.Data;
            theta_err = results.noisyAircraftState.theta_rad.Data - results.aircraftState.theta_rad.Data;
            
            %Compute position error
            n_err = results.noisyAircraftState.n_ft.Data - results.aircraftState.n_ft.Data;
            e_err = results.noisyAircraftState.e_ft.Data - results.aircraftState.e_ft.Data;
            
            %Compute rate error
            ndot_err = results.noisyAircraftStateRate.Ndot_ftps.Data - results.stateRate.Ndot_ftps.Data;
            edot_err = results.noisyAircraftStateRate.Edot_ftps.Data - results.stateRate.Edot_ftps.Data;
            
            %%
            %Ensure errors are normally distributed with the specified
            %standard deviations 
            %
            
            %Heading
            figure('name','GPS-INS');
            title('Heading Error');
            xlabel('Time (s)');
            ylabel('Error (rad)');
            result = makeErrCheckHist(psi_err, mean(psi_err), myOE.psi_random_stddev_rad, yscale, nbins);
            testCase.assertEqual(result, 1, 'OwnshipError Unit Test Failed. (Heading error standard deviation exceeded tolerance)');
            
            if save_
                savefig('Heading.fig');
            end
            
            %Pitch
            figure('name','GPS-INS');
            title('Pitch Error');
            xlabel('Time (s)');
            ylabel('Error (rad)');
            result = makeErrCheckHist(phi_err, mean(phi_err), myOE.phi_random_stddev_rad, yscale, nbins);
            testCase.assertEqual(result, 1, 'OwnshipError Unit Test Failed. (Pitch error standard deviation exceeded tolerance)');
            
            if save_
                savefig('Pitch.fig');
            end
            
            %Bank
            figure('name','GPS-INS');
            title('Bank Error');
            xlabel('Time (s)');
            ylabel('Error (rad)');
            result = makeErrCheckHist(theta_err, mean(theta_err), myOE.theta_random_stddev_rad, yscale, nbins);
            testCase.assertEqual(result, 1, 'OwnshipError Unit Test Failed. (Bank error standard deviation exceeded tolerance)');

            if save_
                savefig('Bank.fig');
            end
            
            %Horizontal Position (North)
            figure('name','GPS-INS');
            title('Horizontal Postion Error (North)');
            xlabel('Time (s)');
            ylabel('Error (ft)');
            result = makeErrCheckHist(n_err, mean(n_err), myOE.y_random_stddev_ft, yscale, nbins);
            testCase.assertEqual(result, 1, 'OwnshipError Unit Test Failed. (Horizontal Postion Error (North) standard deviation exceeded tolerance)');
            
            if save_
                savefig('PosNorth.fig');
            end
            
            %Horizontal Position (East)
            figure('name','GPS-INS');
            title('Horizontal Positon Error (East)');
            xlabel('Time (s)');
            ylabel('Error (ft)');
            result = makeErrCheckHist(e_err, mean(e_err), myOE.x_random_stddev_ft, yscale, nbins);
            testCase.assertEqual(result, 1, 'OwnshipError Unit Test Failed. (Horizontal Postion Error (East) standard deviation exceeded tolerance)');
            
            if save_
                savefig('HeadingRate.fig');
            end
            
            %Horizontal Rate (North)
            figure('name','GPS-INS');
            title('Horizontal Rate Error (North)');
            xlabel('Time (s)');
            ylabel('Error (ftps)');
            makeErrCheckHist(ndot_err, mean(ndot_err), myOE.vy_random_stddev_ftps, yscale, nbins);
            testCase.assertEqual(result, 1, 'OwnshipError Unit Test Failed. (Horizontal Rate Error (North) standard deviation exceeded tolerance)');
            
            if save_
                savefig('NorthRate.fig');
            end
            
            %Horizontal Rate (East)
            figure('name','GPS-INS');
            title('Horizontal Rate Error (East)');
            xlabel('Time (s)');
            ylabel('Error (ftps)');
            result = makeErrCheckHist(edot_err, mean(edot_err), myOE.vx_random_stddev_ftps, yscale, nbins);
            testCase.assertEqual(result, 1, 'OwnshipError Unit Test Failed. (Horizontal Rate Error (East) standard deviation exceeded tolerance)');

            if save_
                savefig('EastRate.fig');
            end
            
            if save_
                if ~exist('own_figures', 'dir')
                    mkdir own_figures;
                end
                
                movefile *.fig own_figures;
            end
        end        
    end
end