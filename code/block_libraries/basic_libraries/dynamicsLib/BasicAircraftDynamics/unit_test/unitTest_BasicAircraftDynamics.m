classdef unitTest_BasicAircraftDynamics < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% Unit Test for Basic Aircraft Dynmaics
% This unit test compares whether events simulated through BAD match expected trajectories from Encounter Model Tool.
% Note that we are implicitly testing the rates (vdot, hdot, psidot) by testing the associated integrals 
% (v, h, psi): that is, if you do not match the integrals, you will also not match the rates

    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');            
            warning off;
            
            % Switch to the current directory
            simDir = which('dynamicsValidationSim.slx');
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
            myBAD = BasicAircraftDynamics('ac1dyn_');
            testCase.assertEqual(myBAD.tunableParameterPrefix,'ac1dyn_',...
                'BasicAircraftDynamics did not initialize correctly.');
        end
        function testProperties(testCase)
            myBAD = BasicAircraftDynamics('ac1dyn_');
            
            %Initial Conditions
            myBAD.v_ftps = 100;
            myBAD.N_ft = 0;
            myBAD.E_ft = 0;
            myBAD.h_ft = 1000;
            myBAD.psi_rad = 0;
            myBAD.theta_rad = 0;
            myBAD.phi_rad = 0;
            myBAD.a_ftpss = 0;
            
            %Lat/lon/alt Coordinates
            myBAD.lat0_rad = 0;
            myBAD.lon0_rad = 0;
            myBAD.alt0_ft = 1000;

            testCase.assertEqual(myBAD.v_ftps,100,'v_ftps was not set correctly');
            testCase.assertEqual(myBAD.N_ft,0,'N_ft was not set correctly');
            testCase.assertEqual(myBAD.E_ft,0,'E_ft was not set correctly');
            testCase.assertEqual(myBAD.h_ft,1000,'h_ft was not set correctly');
            testCase.assertEqual(myBAD.psi_rad,0,'psi_rad was not set correctly');
            testCase.assertEqual(myBAD.theta_rad,0,'theta_rad was not set correctly');
            testCase.assertEqual(myBAD.phi_rad,0,'phi_rad was not set correctly');
            testCase.assertEqual(myBAD.a_ftpss,0,'a_ftpss was not set correctly');
            testCase.assertEqual(myBAD.lat0_rad,0,'lat0_rad was not set correctly');
            testCase.assertEqual(myBAD.lon0_rad,0,'lon0_rad was not set correctly');
            testCase.assertEqual(myBAD.alt0_ft,1000,'alt0_ft was not set correctly');
        end
        function testBasicAircraftDynamics(testCase)
            myBAD = BasicAircraftDynamics('ac1dyn_');
            myBAD.prepareSim();
            
            %Set lat/lon/alt
            myBAD.lat0_rad = 0;
            myBAD.lon0_rad = 0;
            myBAD.alt0_ft = 1000;
            
            % Test thresholds
            v_threshold = 3; % ft/s
            N_threshold = 75; % ft
            E_threshold = 75; % ft
            h_threshold = 20; % ft
            psi_threshold = 2*DEGAS.deg2rad; % rad

            %Allows users to customize figure options (displaying, saving, etc...)
            if exist([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'file')
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'plotFig_BAD');
                if exist('plotFig_BAD','var')
                    display = plotFig_BAD;
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
                load([getenv('DEGAS_HOME'), filesep, 'testing', filesep, 'unitTestParams.mat'],'saveFig_BAD');
                if exist('saveFig_BAD','var')
                    save_ = saveFig_BAD;
                else
                    save_ = false;
                end
            else
                save_ = false;
            end
          
            n = 100; % number of tracks
                        
            folderID = [getenv('DEGAS_HOME') filesep 'block_libraries' filesep 'basic_libraries'...
                filesep 'unitTestUtilities' filesep 'Encounters'];
            
            unzip([folderID filesep 'encounters.zip'], folderID);

            for i = 1:1:n
                encID = i;
                results = readTrajFiles(encID, folderID, 'OWNSHIP', 'INTRUDER');

                % Encounter Controls
                events = open([folderID filesep 'unitTestEncounters.mat']);
                event1 = events.samples(i).updates(1).event';
                assignin('base', 'event1', event1);
                if (exist('event1.mat','var'))
                    delete('event1.mat');
                end
                save event1 event1
                
                myBAD.v_ftps = events.samples(i).v_ftps(1);
                myBAD.N_ft = events.samples(i).n_ft(1);
                myBAD.E_ft = events.samples(i).e_ft(1);
                myBAD.h_ft = events.samples(i).h_ft(1);
                myBAD.psi_rad = events.samples(i).heading_rad(1);
                myBAD.theta_rad = events.samples(i).pitch_rad(1);
                myBAD.phi_rad = events.samples(i).bank_rad(1);
                myBAD.a_ftpss = events.samples(i).a_ftpss(1);
                
                % Initial Conditions
                assignin('base','ac1dyn_v_ftps',myBAD.v_ftps);
                assignin('base','ac1dyn_N_ft',myBAD.N_ft);
                assignin('base','ac1dyn_E_ft',myBAD.E_ft);
                assignin('base','ac1dyn_h_ft',myBAD.h_ft);
                assignin('base','ac1dyn_psi_rad',myBAD.psi_rad);
                assignin('base','ac1dyn_theta_rad',myBAD.theta_rad);
                assignin('base','ac1dyn_phi_rad',myBAD.phi_rad);
                assignin('base','ac1dyn_a_ftpss',myBAD.a_ftpss);

                v_true = results(1).speed_ftps(1:10:end);
                N_true = results(1).north_ft(1:10:end);
                E_true = results(1).east_ft(1:10:end);
                h_true = results(1).up_ft(1:10:end);
                psi_true = results(1).psi_rad(1:10:end); 

                % Simulate
                [~, ~, ~] = sim('dynamicsValidationSim');

                % Calculate errors
                v_error = abs( v_true - v_ftps );
                N_error = abs( N_true - N_ft );
                E_error = abs( E_true - E_ft );
                h_error = abs( h_true - h_ft );
                psi_error = abs(( unwrap(psi_true) - unwrap(psi_rad) ));

                %Check if errors are less than acceptable threshold
                testCase.assertLessThan(v_error,v_threshold,'Basic Aircraft Dynamics Unit Test Failed. (velocity error exceeded threshold)');
                testCase.assertLessThan(N_error,N_threshold,'Basic Aircraft Dynamics Unit Test Failed. (North error exceeded threshold)');
                testCase.assertLessThan(E_error,E_threshold,'Basic Aircraft Dynamics Unit Test Failed. (East error exceeded threshold)');
                testCase.assertLessThan(h_error,h_threshold,'Basic Aircraft Dynamics Unit Test Failed. (alitude error exceed threshold)');
                testCase.assertLessThan(psi_error,psi_threshold,'Basic Aircraft Dynamics Unit Test Failed. (Bearing error exceed threshold)');
               
                h=figure('name', 'Basic Aircraft Dynamics');
                subplot(321);
                plot(v_true,'b-'); hold on; plot(v_ftps,'r:'); ylabel('v (ft/s)');
                subplot(322);
                plot(N_true,'b-'); hold on; plot(N_ft,'r:'); ylabel('n (ft)');
                subplot(323);
                plot(E_true,'b-'); hold on; plot(E_ft,'r:'); ylabel('e (ft)');
                subplot(324);
                plot(h_true,'b-'); hold on; plot(h_ft,'r:'); ylabel('h (ft)');
                subplot(325);
                plot(psi_true,'b-'); hold on; plot(psi_rad,'r:'); ylabel('psi (rad)');
                subplot(326);
                plot(E_true,N_true,'b-'); hold on; plot(E_ft,N_ft,'r:'); 
                axis equal; xlabel('e (ft)'); ylabel('n (ft)');
                set(gcf,'units','normal','position',[.1 .1 .8 .8]); 
                
                if (save_)
                    if ~exist('BAD_figures', 'dir')
                        mkdir BAD_figures;
                    end
                    
                    saveas(h,sprintf('BAD_%d.png',i));
                    movefile *.png BAD_figures
                end
            end
            %Cleanup
            delete event1.mat
        end        
    end
end