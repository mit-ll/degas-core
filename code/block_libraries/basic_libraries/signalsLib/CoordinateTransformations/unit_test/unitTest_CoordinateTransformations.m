classdef unitTest_CoordinateTransformations < matlab.unittest.TestCase
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% UNITTEST_CoordinateTransformations Unit test for the CoordinateTransformations block
% using the Matlab unit testing framework
%
% This object uses the Matlab unit testing framework to test the
% constructor, properties and functionality of the CoordinateTransformations block

    methods (TestMethodSetup)
        function setupPathAndBusDefinitions(testCase)
            % Clear the workspace
            evalin('base','clear all');
            warning off;
            
            % Switch to the current directory 
            simDir = which('unitTestCoordinateTransformations.slx');
            [simDir,~,~] = fileparts(simDir);
            cd(simDir);

            % Populate base workspace with bus_definitions
            bus_definitions();
        end
        function setupVariables(testCase)
            %Cart2Cyl
            x = randi(1e6,1);
            y = randi(1e6,1);
            z = randi(1e6,1);
            
            assignin('base', 'x', x);
            assignin('base', 'y', y);
            assignin('base', 'z', z);
            
            %Cyl2Cart
            r = randi(1e6,1);
            theta = deg2rad(randi(360,1));
            h = randi(1e6,1);

            while (r < h)
                r = randi(1e6,1);
            end

            rh = sqrt(r^2-h^2);
            el = atan(h/rh);
            
            assignin('base', 'r', r);
            assignin('base', 'theta', theta);
            assignin('base', 'h', h);
            assignin('base', 'rh', rh);
            assignin('base', 'el', el);
            
            %Cart2Sph
            xdot = randi(1e6,1);
            ydot = randi(1e6,1);
            zdot = randi(1e6,1);
            
            assignin('base', 'xdot', xdot);
            assignin('base', 'ydot', ydot);
            assignin('base', 'zdot', zdot);
            
            %Sph2Cart
            az_rad = randi(1e6,1);
            el_rad = randi(1e6,1);
            rdot = randi(1e6,1);
            azdot = randi(1e6,1);
            eldot = randi(1e6,1);
            
            assignin('base', 'az_rad', az_rad);
            assignin('base', 'el_rad', el_rad);
            assignin('base', 'rdot', rdot);
            assignin('base', 'azdot', azdot);
            assignin('base', 'eldot', eldot);
            
            %ECEF2LLA
            X = 5027117.64079713;
            Y = -14647198.778317;
            Z = 14026768.7915835;
            
            assignin('base', 'X', X);
            assignin('base', 'Y', Y);
            assignin('base', 'Z', Z);
            
            %LLA2ECEF
            lat = deg2rad(42.361145);
            lon = deg2rad(-71.057083); 
            alt = 141;
            
            assignin('base', 'lat', lat);
            assignin('base', 'lon', lon);
            assignin('base', 'alt', alt);
            
            [~,~,yout] = sim('unitTestCoordinateTransformations.slx');
            
            assignin('base', 'yout', yout);
        end
    end

    % Test Method Block
    % 1) Cartesian to Cylindrical
    % 2) Cylindrical to Cartesian
    % 3) Cartesian to Spherical
    % 4) Spherical to Cartesian
    % 5) Latitude, Longitude, and Altitude to ECEF
    % 6) ECEF to Latitude, Longitude and Altitude
    %
    methods (Test)
        % Test Function
        function testCart2Cyl(testCase)
            tol = 1e-6;
            
            yout = evalin('base','yout');
            x = evalin('base','x');
            y = evalin('base','y');
            z = evalin('base','z');

            rhoOut = yout(:,1);
            thetaOut = yout(:,2);
            hOut = yout(:,3);
            
            [thetaTruth,rhoTruth,hTruth] = cart2pol(x,y,z);
           
            testCase.assertLessThanOrEqual(abs(rhoOut-rhoTruth),tol,'rhoOut exceeded acceptable tolerance level');
            testCase.assertLessThanOrEqual(abs(thetaOut-thetaTruth),tol,'thetaOut exceeded acceptable tolerance level');
            testCase.assertLessThanOrEqual(abs(hOut-hTruth),tol,'hOut exceeded acceptable tolerance level');
        end
        function testCyl2Cart(testCase)
            tol = 1e-6;

            yout = evalin('base','yout');
            theta = evalin('base','theta');
            rh = evalin('base','rh');
            h = evalin('base','h');

            xOutC = yout(:,5);
            yOutC = yout(:,6);
            z_hOut = yout(:,8);
                        
            [xTruth,yTruth,zTruth] = pol2cart(theta,rh,h);
            
            testCase.assertLessThanOrEqual(abs(xOutC-xTruth),tol,'xOutC exceeded acceptable tolerance level');
            testCase.assertLessThanOrEqual(abs(yOutC-yTruth),tol,'yOutC exceeded acceptable tolerance level');
            testCase.assertLessThanOrEqual(abs(z_hOut-zTruth),tol,'z_hOut exceeded acceptable tolerance level');
        end
        function testCart2Sph_degas(testCase)
            tol = 1e-6;

            yout = evalin('base','yout');
            x = evalin('base','x');
            y = evalin('base','y');
            z = evalin('base','z');

            rangeOut = yout(:,9);
            azOut = yout(:,10);
            elOut = yout(:,11);

            azTruth = atan2(y,x);
            elTruth = -1*atan2(z,sqrt(x.^2 + y.^2));
            rTruth = sqrt(x.^2 + y.^2 + z.^2);

            testCase.assertLessThanOrEqual(abs(rangeOut-rTruth),tol,'rangeOut exceeded acceptable tolerance level');
            testCase.assertLessThanOrEqual(abs(azOut-azTruth),tol,'azOut exceeded acceptable tolerance level');
            testCase.assertLessThanOrEqual(abs(elOut-elTruth),tol,'elOut exceeded acceptable tolerance level');
        end
        function testSph2Cart(testCase)
            tol = 1e-6;

            yout = evalin('base','yout');
            az_rad = evalin('base','az_rad');
            el_rad = evalin('base','el_rad');
            r = evalin('base', 'r');
         
            xOutS = yout(:,15);
            yOutS = yout(:,16);
            zOutS = yout(:,17);
            
            xTruth_ = r .* cos(el_rad) .* cos(az_rad);
            yTruth_ = r .* cos(el_rad) .* sin(az_rad);
            zTruth_ = -1 * r .* sin(el_rad);
            
            testCase.assertLessThanOrEqual(abs(xOutS-xTruth_),tol,'xOutS exceeded acceptable tolerance level');
            testCase.assertLessThanOrEqual(abs(yOutS-yTruth_),tol,'yOutS exceeded acceptable tolerance level');
            testCase.assertLessThanOrEqual(abs(zOutS-zTruth_),tol,'zOutS exceeded acceptable tolerance level');
        end
        function testECEF2LLA(testCase)
            tol = 1e-6;

            yout = evalin('base','yout');
            X = evalin('base','X');
            Y = evalin('base','Y');
            Z = evalin('base','Z');

            latOut = yout(:,21);
            lonOut = yout(:,22);
            ehOut = yout(:,23);
            
            spheroid = wgs84Ellipsoid('feet');
            [true_lat,true_lon,true_eh] = ecef2geodetic(spheroid,X,Y,Z);
            
            testCase.assertLessThanOrEqual(abs(latOut-deg2rad(true_lat)),tol,'latOut exceeded acceptable tolerance level');
            testCase.assertLessThanOrEqual(abs(lonOut-deg2rad(true_lon)),tol,'lonOut exceeded acceptable tolerance level');
            testCase.assertLessThanOrEqual(abs(ehOut-true_eh),tol,'ehOut exceeded acceptable tolerance level');
        end
        function testLLA2ECEF(testCase)
            tol = 1e-6;

            yout = evalin('base','yout');
            lat = evalin('base','lat');
            lon = evalin('base','lon');
            alt = evalin('base','alt');
    
            XOut = yout(:,24);
            YOut = yout(:,25);
            ZOut = yout(:,26);
            
            spheroid = wgs84Ellipsoid('feet');
            [true_X,true_Y,true_Z] = geodetic2ecef(spheroid,lat,lon,alt,'radians');
            
            testCase.assertLessThanOrEqual(abs(XOut-true_X),tol,'XOut exceeded acceptable tolerance level');
            testCase.assertLessThanOrEqual(abs(YOut-true_Y),tol,'YOut exceeded acceptable tolerance level');
            testCase.assertLessThanOrEqual(abs(ZOut-true_Z),tol,'ZOut exceeded acceptable tolerance level');
        end
    end
end