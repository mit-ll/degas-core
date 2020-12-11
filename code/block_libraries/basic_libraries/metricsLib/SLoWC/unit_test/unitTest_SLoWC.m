classdef unitTest_SLoWC < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_SLoWC Unit test for the SLoWC block using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the SLoWC block
    
    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;
            
            % Switch to the current directory
            simDir = which('unitTestSLoWC.slx');
            [simDir,~,~] = fileparts(simDir);
            cd(simDir);
            
            % Populate base workspace with bus_definitions
            bus_definitions();
        end
    end
    
    % Test Method Block
    methods (Test)
        function testSLoWC(testCase)
            %Modfied range
            DMOD = 4000;
            %Modified tau
            tau_mod = 35;
            %Range Rate
            rdot = 0;
            altDiffThreshold = 450;
            
            %Horizontal miss distance
            HMD = timeseries(100);
            %Altitude difference
            DH = timeseries(100);
            Range = timeseries(sqrt((DH.Data)^2 + (HMD.Data)^2));
            horzProx = timeseries(max(DMOD, 0.5*(sqrt((rdot*tau_mod)^2+(4*DMOD^2))-rdot*tau_mod)));
            
            assignin('base','HMD',HMD);
            assignin('base','DH',DH);
            assignin('base','Range',Range);
            assignin('base','horzProx',horzProx);
            
            [~,~,~] = sim('unitTestSLoWC.slx');
            
            %SLoWC = (1 - RangePen (+) HMDPen (+) VertPen)*100
            %RangePen
            rp = min(Range.Data(1)/horzProx.Data(1),1);
            %HMDPen
            hp = min(HMD.Data(1)/DMOD, 1);
            %VertPen
            vp = min(abs(DH.Data(1))/altDiffThreshold,1);
            
            %Compute fg norm twice
            fg1 = sqrt(hp^2+(1-hp^2)*vp^2);
            fg2 = sqrt(fg1^2+(1-fg1^2)*rp^2);
            
            %Compute SLoWC
            SLoWC = (1 - fg2)*100;
            
            %SLoWC must be between 0-100 
            testCase.assertEqual(slowc, SLoWC, 'SLoWC Unit Test failed. (SLoWC was not computed correctly)');
        end        
    end
end