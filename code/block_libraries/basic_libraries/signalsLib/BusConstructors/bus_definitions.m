function bus_definitions() 
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%

% bus_definitions: initializes a set of bus objects in the MATLAB
% base workspace
% The bus definitions must be in the base workspace for almost all DEGAS
% simulations to work correctly. 

%==========================================================================
% BUILDING BLOCK BUSES
%==========================================================================

%--------------------------------------------------------------------------
% Bus object: LatLonAltMeasurement
clear elems;

% lat_rad is latitude in radians.
elems(1) = Simulink.BusElement;
elems(1).Name = 'lat_rad';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).SamplingMode = 'Sample based';
elems(1).Min = [];
elems(1).Max = [];

% lon_rad is longitude in radians.
elems(2) = Simulink.BusElement;
elems(2).Name = 'lon_rad';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).SamplingMode = 'Sample based';
elems(2).Min = [];
elems(2).Max = [];

% alt_ft is the altitude in feet.
elems(5) = Simulink.BusElement;
elems(5).Name = 'alt_ft';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).SamplingMode = 'Sample based';
elems(5).Min = [];
elems(5).Max = [];

% dLat_radps is the change in latitude in radians per second.
elems(3) = Simulink.BusElement;
elems(3).Name = 'dlat_radps';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).SamplingMode = 'Sample based';
elems(3).Min = [];
elems(3).Max = [];

% dLon_radps is the change in longitude in radians per second.
elems(4) = Simulink.BusElement;
elems(4).Name = 'dlon_radps';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).SamplingMode = 'Sample based';
elems(4).Min = [];
elems(4).Max = [];

% dh_ftps is the change in altitude in feet per second.
elems(6) = Simulink.BusElement;
elems(6).Name = 'dalt_ftps';
elems(6).Dimensions = 1;
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).SampleTime = -1;
elems(6).Complexity = 'real';
elems(6).SamplingMode = 'Sample based';
elems(6).Min = [];
elems(6).Max = [];

LatLonAltMeasurement = Simulink.Bus;
LatLonAltMeasurement.HeaderFile = '';
LatLonAltMeasurement.Description = sprintf('A measurement in latitude, longitude, and altitude in radians and feet with the WHS84 ellipsoid as the reference.');
LatLonAltMeasurement.DataScope = 'Auto';
LatLonAltMeasurement.Alignment = -1;
LatLonAltMeasurement.Elements = elems;
assigninContext('LatLonAltMeasurement', LatLonAltMeasurement)

%--------------------------------------------------------------------------
% Bus object: StateEstimate
clear elems;

% n_ft is the North position in feet.
elems(1) = Simulink.BusElement;
elems(1).Name = 'n_ft';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).SamplingMode = 'Sample based';
elems(1).Min = [];
elems(1).Max = [];

% e_ft is the East position in feet.
elems(2) = Simulink.BusElement;
elems(2).Name = 'e_ft';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).SamplingMode = 'Sample based';
elems(2).Min = [];
elems(2).Max = [];

% h_ft is the altitude in feet.
elems(3) = Simulink.BusElement;
elems(3).Name = 'h_ft';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).SamplingMode = 'Sample based';
elems(3).Min = [];
elems(3).Max = [];

% dN_ftps is the change in North position in feet per second.
elems(4) = Simulink.BusElement;
elems(4).Name = 'dn_ftps';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).SamplingMode = 'Sample based';
elems(4).Min = [];
elems(4).Max = [];

% dE_ftps is the change in East position in feet per second.
elems(5) = Simulink.BusElement;
elems(5).Name = 'de_ftps';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).SamplingMode = 'Sample based';
elems(5).Min = [];
elems(5).Max = [];

% dH_ftps is the change in altitude in feet per second.
elems(6) = Simulink.BusElement;
elems(6).Name = 'dh_ftps';
elems(6).Dimensions = 1;
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).SampleTime = -1;
elems(6).Complexity = 'real';
elems(6).SamplingMode = 'Sample based';
elems(6).Min = [];
elems(6).Max = [];

StateEstimate = Simulink.Bus;
StateEstimate.HeaderFile = '';
StateEstimate.Description = sprintf('Based upon the dynamics of the aircraft, the most likely estimate of an aircraft''s state.');
StateEstimate.DataScope = 'Auto';
StateEstimate.Alignment = -1;
StateEstimate.Elements = elems;
assigninContext('StateEstimate', StateEstimate)

%--------------------------------------------------------------------------
% Bus object: CovarianceEstimate- note variances are specified, but these
% can be used to form the covariance matrix. (Var(a) = Cov(a,a))
clear elems;

% nVar_ft2 is the variance of error in the estimate of the North position
elems(1) = Simulink.BusElement;
elems(1).Name = 'nVar_ft2';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).SamplingMode = 'Sample based';
elems(1).Min = [];
elems(1).Max = [];

% eVar_ft2 is the variance of error in the estimate of the East position
elems(2) = Simulink.BusElement;
elems(2).Name = 'eVar_ft2';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).SamplingMode = 'Sample based';
elems(2).Min = [];
elems(2).Max = [];

% hVar_ft2 is the variance of error in the estimate of the altitude
elems(3) = Simulink.BusElement;
elems(3).Name = 'hVar_ft2';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).SamplingMode = 'Sample based';
elems(3).Min = [];
elems(3).Max = [];

% dnVar_ft2ps2 is the variance of error in the estimate of the change in
% North position
elems(4) = Simulink.BusElement;
elems(4).Name = 'dnVar_ft2ps2';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).SamplingMode = 'Sample based';
elems(4).Min = [];
elems(4).Max = [];

% deVar_ft2ps2 is the variance of error in the estimate of the change in
% East position
elems(5) = Simulink.BusElement;
elems(5).Name = 'deVar_ft2ps2';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).SamplingMode = 'Sample based';
elems(5).Min = [];
elems(5).Max = [];

% dhVar_ft2ps2 is the variance of error in the estimate of the change in
% altitude
elems(6) = Simulink.BusElement;
elems(6).Name = 'dhVar_ft2ps2';
elems(6).Dimensions = 1;
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).SampleTime = -1;
elems(6).Complexity = 'real';
elems(6).SamplingMode = 'Sample based';
elems(6).Min = [];
elems(6).Max = [];

CovarianceEstimate = Simulink.Bus;
CovarianceEstimate.HeaderFile = '';
CovarianceEstimate.Description = sprintf('Observable estimate of the unobservable statistical error in the aircraft state\n(i.e., covariance matrix in a Kalman filter)');
CovarianceEstimate.DataScope = 'Auto';
CovarianceEstimate.Alignment = -1;
CovarianceEstimate.Elements = elems;
assigninContext('CovarianceEstimate', CovarianceEstimate)

%==========================================================================
% AIRCRAFT MODEL INTERFACE BUSES
%==========================================================================

%--------------------------------------------------------------------------
% Bus object: AircraftEstimate Output By: Observation Block Input To: Logic
% and Response Block

clear elems;

% timeOfValidity is the time of validity for the aircraft esitmate
elems(2) = Simulink.BusElement;
elems(2).Name = 'timeOfValidity';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).SamplingMode = 'Sample based';
elems(2).Min = [];
elems(2).Max = [];

% isValid is set to true if the rest of the fields apply to an actual
% aircraft and false otherwise.
elems(3) = Simulink.BusElement;
elems(3).Name = 'isValid';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'boolean';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).SamplingMode = 'Sample based';
elems(3).Min = [];
elems(3).Max = [];

% enuStateEsitmate is the East, North, Up position of the aircraft and the
% change in each of those position measurements.
elems(4) = Simulink.BusElement;
elems(4).Name = 'enuStateEstimate';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'Bus: StateEstimate';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).SamplingMode = 'Sample based';
elems(4).Min = [];
elems(4).Max = [];

% latLonAltEst is the latitude, longitude, and altitude position of the
% aircraft and change in each of those position measurements.
elems(1) = Simulink.BusElement;
elems(1).Name = 'latLonAltEst';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'Bus: LatLonAltMeasurement';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).SamplingMode = 'Sample based';
elems(1).Min = [];
elems(1).Max = [];

% covEstimate is the 6 element covariance estimate of the aircraft position
% in ENU.
elems(5) = Simulink.BusElement;
elems(5).Name = 'covEstimate';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'Bus: CovarianceEstimate';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).SamplingMode = 'Sample based';
elems(5).Min = [];
elems(5).Max = [];

AircraftEstimate = Simulink.Bus;
AircraftEstimate.HeaderFile = '';
AircraftEstimate.Description = sprintf('An estimate of an aircraft''s position and covariance. ');
AircraftEstimate.DataScope = 'Auto';
AircraftEstimate.Alignment = -1;
AircraftEstimate.Elements = elems;
assigninContext('AircraftEstimate', AircraftEstimate)

%--------------------------------------------------------------------------
% Bus object: RadarSurveillance Output By: Observation Block (optional)
% Input To: Logic and Response Block (optional)

clear elems;

% timeOfValidity is the time of validity for the radar surveillance report.
elems(15) = Simulink.BusElement;
elems(15).Name = 'timeOfValidity';
elems(15).Dimensions = 1;
elems(15).DimensionsMode = 'Fixed';
elems(15).DataType = 'double';
elems(15).SampleTime = -1;
elems(15).Complexity = 'real';
elems(15).SamplingMode = 'Sample based';
elems(15).Min = [];
elems(15).Max = [];

% isValid is set to true if the rest of the fields apply to an actual
% aircraft and false otherwise.
elems(14) = Simulink.BusElement;
elems(14).Name = 'isValid';
elems(14).Dimensions = 1;
elems(14).DimensionsMode = 'Fixed';
elems(14).DataType = 'boolean';
elems(14).SampleTime = -1;
elems(14).Complexity = 'real';
elems(14).SamplingMode = 'Sample based';
elems(14).Min = [];
elems(14).Max = [];

% SecondarySurv is secondary transponder surveillance information including
% mode code information.
elems(1) = Simulink.BusElement;
elems(1).Name = 'secondarySurv';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'Bus: TransponderSurveillance';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).SamplingMode = 'Sample based';
elems(1).Min = [];
elems(1).Max = [];

% doppler_ftps is the dopper measurement in feet per second.
elems(3) = Simulink.BusElement;
elems(3).Name = 'doppler_ftps';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).SamplingMode = 'Sample based';
elems(3).Min = [];
elems(3).Max = [];

% range_ft is the range of the aircraft measured from the radar in feet.
elems(11) = Simulink.BusElement;
elems(11).Name = 'range_ft';
elems(11).Dimensions = 1;
elems(11).DimensionsMode = 'Fixed';
elems(11).DataType = 'double';
elems(11).SampleTime = -1;
elems(11).Complexity = 'real';
elems(11).SamplingMode = 'Sample based';
elems(11).Min = [];
elems(11).Max = [];

% azimuth_rad is the azimuth of the aircraft measured from the radar in
% radians.
elems(12) = Simulink.BusElement;
elems(12).Name = 'azimuth_rad';
elems(12).Dimensions = 1;
elems(12).DimensionsMode = 'Fixed';
elems(12).DataType = 'double';
elems(12).SampleTime = -1;
elems(12).Complexity = 'real';
elems(12).SamplingMode = 'Sample based';
elems(12).Min = [];
elems(12).Max = [];

% elevation_rad is the elevation angle of the aircraft measured from the
% radar in radians.
elems(13) = Simulink.BusElement;
elems(13).Name = 'elevation_rad';
elems(13).Dimensions = 1;
elems(13).DimensionsMode = 'Fixed';
elems(13).DataType = 'double';
elems(13).SampleTime = -1;
elems(13).Complexity = 'real';
elems(13).SamplingMode = 'Sample based';
elems(13).Min = [];
elems(13).Max = [];

% dopplerVar_ft2ps2 is the variance of error in the estimate of the doppler
elems(2) = Simulink.BusElement;
elems(2).Name = 'dopplerVar_ft2ps2';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).SamplingMode = 'Sample based';
elems(2).Min = [];
elems(2).Max = [];

% rangeVar_ft2 is the variance of error in the estimate of the range
elems(6) = Simulink.BusElement;
elems(6).Name = 'rangeVar_ft2';
elems(6).Dimensions = 1;
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).SampleTime = -1;
elems(6).Complexity = 'real';
elems(6).SamplingMode = 'Sample based';
elems(6).Min = [];
elems(6).Max = [];

% azimuthVar_rad2 is the variance of error in the estimate of the azimuth
elems(5) = Simulink.BusElement;
elems(5).Name = 'azimuthVar_rad2';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).SamplingMode = 'Sample based';
elems(5).Min = [];
elems(5).Max = [];

% elevationVar_rad2 is the variance of error in the estimate of the
% elevation
elems(4) = Simulink.BusElement;
elems(4).Name = 'elevationVar_rad2';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).SamplingMode = 'Sample based';
elems(4).Min = [];
elems(4).Max = [];

% isAirborne is true if the radar taking the measurement is an airborne
% radar and false if it is a ground-based radar.
elems(7) = Simulink.BusElement;
elems(7).Name = 'isAirborne';
elems(7).Dimensions = 1;
elems(7).DimensionsMode = 'Fixed';
elems(7).DataType = 'boolean';
elems(7).SampleTime = -1;
elems(7).Complexity = 'real';
elems(7).SamplingMode = 'Sample based';
elems(7).Min = [];
elems(7).Max = [];

% nRadar_ft is the North position in ENU of the radar in feet.
elems(8) = Simulink.BusElement;
elems(8).Name = 'nRadar_ft';
elems(8).Dimensions = 1;
elems(8).DimensionsMode = 'Fixed';
elems(8).DataType = 'double';
elems(8).SampleTime = -1;
elems(8).Complexity = 'real';
elems(8).SamplingMode = 'Sample based';
elems(8).Min = [];
elems(8).Max = [];

% eRadar_ft is the East position in ENU of the radar in feet.
elems(9) = Simulink.BusElement;
elems(9).Name = 'eRadar_ft';
elems(9).Dimensions = 1;
elems(9).DimensionsMode = 'Fixed';
elems(9).DataType = 'double';
elems(9).SampleTime = -1;
elems(9).Complexity = 'real';
elems(9).SamplingMode = 'Sample based';
elems(9).Min = [];
elems(9).Max = [];

% hRadar_ft is the altitude in ENU of the radar in feet.
elems(10) = Simulink.BusElement;
elems(10).Name = 'hRadar_ft';
elems(10).Dimensions = 1;
elems(10).DimensionsMode = 'Fixed';
elems(10).DataType = 'double';
elems(10).SampleTime = -1;
elems(10).Complexity = 'real';
elems(10).SamplingMode = 'Sample based';
elems(10).Min = [];
elems(10).Max = [];

RadarSurveillance = Simulink.Bus;
RadarSurveillance.HeaderFile = '';
RadarSurveillance.Description = sprintf('A report of an aircraft position similar to what a radar would produce and includes radar location.');
RadarSurveillance.DataScope = 'Auto';
RadarSurveillance.Alignment = -1;
RadarSurveillance.Elements = elems;
assigninContext('RadarSurveillance', RadarSurveillance)

%--------------------------------------------------------------------------
% Bus object: AircraftCommands Output By: Logic and Response Block Input
% To: Dynamics Block

clear elems;

% h_flag is set to true when the h_ftps element is filled and false
% otherwise.
elems(1) = Simulink.BusElement;
elems(1).Name = 'h_flag';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'boolean';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).SamplingMode = 'Sample based';
elems(1).Min = [];
elems(1).Max = [];

% h_ftps is the commanded vertical rate to attain in feet per second.
elems(2) = Simulink.BusElement;
elems(2).Name = 'h_ft';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).SamplingMode = 'Sample based';
elems(2).Min = [];
elems(2).Max = [];

% v_flag is set to true when the v_ftps element is filled and false
% otherwise.
elems(3) = Simulink.BusElement;
elems(3).Name = 'v_flag';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'boolean';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).SamplingMode = 'Sample based';
elems(3).Min = [];
elems(3).Max = [];

% v_ftps is the velocity to achieve in feet per second.
elems(4) = Simulink.BusElement;
elems(4).Name = 'v_ftps';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).SamplingMode = 'Sample based';
elems(4).Min = [];
elems(4).Max = [];
elems(4).Description = 'v_ftps is the velocity to achieve in feet per second';

% phi_flag is set to true when the phi_rad element is filled and false
% otherwise.
elems(5) = Simulink.BusElement;
elems(5).Name = 'phi_flag';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'boolean';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).SamplingMode = 'Sample based';
elems(5).Min = [];
elems(5).Max = [];

% phi_rad is the bank angle to achieve in radians.
elems(6) = Simulink.BusElement;
elems(6).Name = 'phi_rad';
elems(6).Dimensions = 1;
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).SampleTime = -1;
elems(6).Complexity = 'real';
elems(6).SamplingMode = 'Sample based';
elems(6).Min = [];
elems(6).Max = [];

% theta_flag is set to true when the theta_rad element is filled and false
% otherwise.
elems(15) = Simulink.BusElement;
elems(15).Name = 'theta_flag';
elems(15).Dimensions = 1;
elems(15).DimensionsMode = 'Fixed';
elems(15).DataType = 'boolean';
elems(15).SampleTime = -1;
elems(15).Complexity = 'real';
elems(15).SamplingMode = 'Sample based';
elems(15).Min = [];
elems(15).Max = [];

% theta_rad is the pitch angle in radians.
elems(16) = Simulink.BusElement;
elems(16).Name = 'theta_rad';
elems(16).Dimensions = 1;
elems(16).DimensionsMode = 'Fixed';
elems(16).DataType = 'double';
elems(16).SampleTime = -1;
elems(16).Complexity = 'real';
elems(16).SamplingMode = 'Sample based';
elems(16).Min = [];
elems(16).Max = [];

% dh_flag is set to true when the dh_ftps element is filled and false
% otherwise.
elems(7) = Simulink.BusElement;
elems(7).Name = 'dh_flag';
elems(7).Dimensions = 1;
elems(7).DimensionsMode = 'Fixed';
elems(7).DataType = 'boolean';
elems(7).SampleTime = -1;
elems(7).Complexity = 'real';
elems(7).SamplingMode = 'Sample based';
elems(7).Min = [];
elems(7).Max = [];

% dh_ftps is the vertical rate to attain in feet per second.
elems(8) = Simulink.BusElement;
elems(8).Name = 'dh_ftps';
elems(8).Dimensions = 1;
elems(8).DimensionsMode = 'Fixed';
elems(8).DataType = 'double';
elems(8).SampleTime = -1;
elems(8).Complexity = 'real';
elems(8).SamplingMode = 'Sample based';
elems(8).Min = [];
elems(8).Max = [];

% dv_flag is set to true when the dv_ftps2 element is filled and false
% otherwise.
elems(9) = Simulink.BusElement;
elems(9).Name = 'dv_flag';
elems(9).Dimensions = 1;
elems(9).DimensionsMode = 'Fixed';
elems(9).DataType = 'boolean';
elems(9).SampleTime = -1;
elems(9).Complexity = 'real';
elems(9).SamplingMode = 'Sample based';
elems(9).Min = [];
elems(9).Max = [];

% dv_ftps2 is the acceleration in feet per second squared.
elems(10) = Simulink.BusElement;
elems(10).Name = 'dv_ftps2';
elems(10).Dimensions = 1;
elems(10).DimensionsMode = 'Fixed';
elems(10).DataType = 'double';
elems(10).SampleTime = -1;
elems(10).Complexity = 'real';
elems(10).SamplingMode = 'Sample based';
elems(10).Min = [];
elems(10).Max = [];

% dpsi_flag is set to true when the dpsi_radps element is filled and false
% otherwise.
elems(11) = Simulink.BusElement;
elems(11).Name = 'dpsi_flag';
elems(11).Dimensions = 1;
elems(11).DimensionsMode = 'Fixed';
elems(11).DataType = 'boolean';
elems(11).SampleTime = -1;
elems(11).Complexity = 'real';
elems(11).SamplingMode = 'Sample based';
elems(11).Min = [];
elems(11).Max = [];

% dpsi_radps is the turn acceleration in radians per second.
elems(12) = Simulink.BusElement;
elems(12).Name = 'dpsi_radps';
elems(12).Dimensions = 1;
elems(12).DimensionsMode = 'Fixed';
elems(12).DataType = 'double';
elems(12).SampleTime = -1;
elems(12).Complexity = 'real';
elems(12).SamplingMode = 'Sample based';
elems(12).Min = [];
elems(12).Max = [];

% ddh_flag is set to true when the ddH_ftps2 element is filled and false
% otherwise.
elems(13) = Simulink.BusElement;
elems(13).Name = 'ddh_flag';
elems(13).Dimensions = 1;
elems(13).DimensionsMode = 'Fixed';
elems(13).DataType = 'boolean';
elems(13).SampleTime = -1;
elems(13).Complexity = 'real';
elems(13).SamplingMode = 'Sample based';
elems(13).Min = [];
elems(13).Max = [];

% ddh_ftps2 is the vertical acceleration in feet per second squared.
elems(14) = Simulink.BusElement;
elems(14).Name = 'ddh_ftps2';
elems(14).Dimensions = 1;
elems(14).DimensionsMode = 'Fixed';
elems(14).DataType = 'double';
elems(14).SampleTime = -1;
elems(14).Complexity = 'real';
elems(14).SamplingMode = 'Sample based';
elems(14).Min = [];
elems(14).Max = [];

% ddz_flag is set to true when the ddZ_ftps2 element is filled and false
% otherwise.
elems(17) = Simulink.BusElement;
elems(17).Name = 'ddz_flag';
elems(17).Dimensions = 1;
elems(17).DimensionsMode = 'Fixed';
elems(17).DataType = 'boolean';
elems(17).SampleTime = -1;
elems(17).Complexity = 'real';
elems(17).SamplingMode = 'Sample based';
elems(17).Min = [];
elems(17).Max = [];

% ddz_ftps2 is the body frame acceleration in feet per second squared.
elems(18) = Simulink.BusElement;
elems(18).Name = 'ddz_ftps2';
elems(18).Dimensions = 1;
elems(18).DimensionsMode = 'Fixed';
elems(18).DataType = 'double';
elems(18).SampleTime = -1;
elems(18).Complexity = 'real';
elems(18).SamplingMode = 'Sample based';
elems(18).Min = [];
elems(18).Max = [];

% psi_flag is set to true when the aircraft should follow heading commands
elems(19) = Simulink.BusElement;
elems(19).Name = 'psi_flag';
elems(19).Dimensions = 1;
elems(19).DimensionsMode = 'Fixed';
elems(19).DataType = 'boolean';
elems(19).SampleTime = -1;
elems(19).Complexity = 'real';
elems(19).SamplingMode = 'Sample based';
elems(19).Min = 0;
elems(19).Max = 1;
elems(19).Description = 'should aircraft follow heading commands';

% psi_rad is the yaw heading angle (relative to due North) in radians.
elems(20) = Simulink.BusElement;
elems(20).Name = 'psi_rad';
elems(20).Dimensions = 1;
elems(20).DimensionsMode = 'Fixed';
elems(20).DataType = 'double';
elems(20).SampleTime = -1;
elems(20).Complexity = 'real';
elems(20).SamplingMode = 'Sample based';
elems(20).Min = -2*pi;
elems(20).Max =  2*pi;
elems(20).DocUnits = 'rad';
elems(20).Description = 'yaw heading angle (relative to due North)';

AircraftCommands = Simulink.Bus;
AircraftCommands.HeaderFile = '';
AircraftCommands.Description = sprintf('Variables that define how the aircraft maneuvers.  \nThis is output by the logic and input by the dynamics');
AircraftCommands.DataScope = 'Auto';
AircraftCommands.Alignment = -1;
AircraftCommands.Elements = elems;
assigninContext('AircraftCommands', AircraftCommands)

%--------------------------------------------------------------------------
% Bus object: AircraftState Output By: Dynamics Block Input To: Observation
% Block and Out of the Aircraft Model

clear elems;

% latLonAltState is the latitude, longitude, and altitude position of the
% aircraft and change in each of those position measurements.
elems(1) = Simulink.BusElement;
elems(1).Name = 'latLonAltState';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'Bus: LatLonAltMeasurement';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).SamplingMode = 'Sample based';
elems(1).Min = [];
elems(1).Max = [];

% v_ftps is the velocity of the aircraft in feet per second.
elems(2) = Simulink.BusElement;
elems(2).Name = 'v_ftps';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).SamplingMode = 'Sample based';
elems(2).Min = [];
elems(2).Max = [];
elems(2).Description = 'v_ftps is the velocity of the aircraft in feet per second';

% n_ft is the North position in ENU of the aircraft.
elems(3) = Simulink.BusElement;
elems(3).Name = 'n_ft';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).SamplingMode = 'Sample based';
elems(3).Min = [];
elems(3).Max = [];

% e_ft is the East position in ENU of the aircraft.
elems(4) = Simulink.BusElement;
elems(4).Name = 'e_ft';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).SamplingMode = 'Sample based';
elems(4).Min = [];
elems(4).Max = [];

% h_ft is the altitude in ENU of the aircraft.
elems(5) = Simulink.BusElement;
elems(5).Name = 'h_ft';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).SamplingMode = 'Sample based';
elems(5).Min = [];
elems(5).Max = [];

% psi_rad is the heading angle in radians.
elems(6) = Simulink.BusElement;
elems(6).Name = 'psi_rad';
elems(6).Dimensions = 1;
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).SampleTime = -1;
elems(6).Complexity = 'real';
elems(6).SamplingMode = 'Sample based';
elems(6).Min = [];
elems(6).Max = [];
elems(6).Description = 'psi_rad is the heading angle in radians.';

% theta_rad is the pitch angle in radians.
elems(7) = Simulink.BusElement;
elems(7).Name = 'theta_rad';
elems(7).Dimensions = 1;
elems(7).DimensionsMode = 'Fixed';
elems(7).DataType = 'double';
elems(7).SampleTime = -1;
elems(7).Complexity = 'real';
elems(7).SamplingMode = 'Sample based';
elems(7).Min = [];
elems(7).Max = [];
elems(7).Description = 'theta_rad is the pitch angle in radians.';

% phi_rad is the bank angle in radians.
elems(8) = Simulink.BusElement;
elems(8).Name = 'phi_rad';
elems(8).Dimensions = 1;
elems(8).DimensionsMode = 'Fixed';
elems(8).DataType = 'double';
elems(8).SampleTime = -1;
elems(8).Complexity = 'real';
elems(8).SamplingMode = 'Sample based';
elems(8).Min = [];
elems(8).Max = [];
elems(8).Description = 'phi_rad is the bank angle in radians.';

% p_radps is the angular velocity around the body x-axis in radians per
% second.
elems(9) = Simulink.BusElement;
elems(9).Name = 'p_radps';
elems(9).Dimensions = 1;
elems(9).DimensionsMode = 'Fixed';
elems(9).DataType = 'double';
elems(9).SampleTime = -1;
elems(9).Complexity = 'real';
elems(9).SamplingMode = 'Sample based';
elems(9).Min = [];
elems(9).Max = [];
elems(9).Description = 'p_radps is the angular velocity around the body x-axis in radians per second.';

% q_radps is the angular velocity around the body y-axis in radians per
% second.
elems(10) = Simulink.BusElement;
elems(10).Name = 'q_radps';
elems(10).Dimensions = 1;
elems(10).DimensionsMode = 'Fixed';
elems(10).DataType = 'double';
elems(10).SampleTime = -1;
elems(10).Complexity = 'real';
elems(10).SamplingMode = 'Sample based';
elems(10).Min = [];
elems(10).Max = [];
elems(10).Description = 'q_radps is the angular velocity around the body y-axis in radians per second.';

% r_radps is the angular velocity around the body z-axis in radians per
% second.
elems(11) = Simulink.BusElement;
elems(11).Name = 'r_radps';
elems(11).Dimensions = 1;
elems(11).DimensionsMode = 'Fixed';
elems(11).DataType = 'double';
elems(11).SampleTime = -1;
elems(11).Complexity = 'real';
elems(11).SamplingMode = 'Sample based';
elems(11).Min = [];
elems(11).Max = [];
elems(11).Description = 'r_radps is the angular velocity around the body z-axis in radians per second.';

% dv_ftps2 is the aircraft's acceleration in feet per second squared.
elems(12) = Simulink.BusElement;
elems(12).Name = 'dv_ftps2';
elems(12).Dimensions = 1;
elems(12).DimensionsMode = 'Fixed';
elems(12).DataType = 'double';
elems(12).SampleTime = -1;
elems(12).Complexity = 'real';
elems(12).SamplingMode = 'Sample based';
elems(12).Min = [];
elems(12).Max = [];
elems(12).Description = 'dv_ftps2 is the aircraft''s acceleration in feet per second squared.';

% dh_ftps is the aircraft's vertical rate in feet per second.
elems(13) = Simulink.BusElement;
elems(13).Name = 'dh_ftps';
elems(13).Dimensions = 1;
elems(13).DimensionsMode = 'Fixed';
elems(13).DataType = 'double';
elems(13).SampleTime = -1;
elems(13).Complexity = 'real';
elems(13).SamplingMode = 'Sample based';
elems(13).Min = [];
elems(13).Max = [];
elems(13).Description = 'dh_ftps is the aircraft''s vertical rate in feet per second.';

% ddh_ftps2 is the aircraft's vertical acceleration in feet per second
% squared.
elems(14) = Simulink.BusElement;
elems(14).Name = 'ddh_ftps2';
elems(14).Dimensions = 1;
elems(14).DimensionsMode = 'Fixed';
elems(14).DataType = 'double';
elems(14).SampleTime = -1;
elems(14).Complexity = 'real';
elems(14).SamplingMode = 'Sample based';
elems(14).Min = [];
elems(14).Max = [];
elems(14).Description = 'ddh_ftps2 is the aircraft''s vertical acceleration in feet per second squared.';

AircraftState = Simulink.Bus;
AircraftState.HeaderFile = '';
AircraftState.Description = sprintf('Variables that describe aircraft state.');
AircraftState.DataScope = 'Auto';
AircraftState.Alignment = -1;
AircraftState.Elements = elems;
assigninContext('AircraftState', AircraftState)

%==========================================================================
% SPECIALTY INTERFACE BUSES
%==========================================================================

%--------------------------------------------------------------------------
% Bus object: AircraftConstraints
clear elems;

elems(1) = Simulink.BusElement;
elems(1).Name = 'v_ftps_max';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).SamplingMode = 'Sample based';
elems(1).Min = [];
elems(1).Max = [];

elems(2) = Simulink.BusElement;
elems(2).Name = 'v_ftps_min';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).SamplingMode = 'Sample based';
elems(2).Min = [];
elems(2).Max = [];

elems(3) = Simulink.BusElement;
elems(3).Name = 'dv_ftps2_max';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).SamplingMode = 'Sample based';
elems(3).Min = [];
elems(3).Max = [];

elems(4) = Simulink.BusElement;
elems(4).Name = 'dv_ftps2_min';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).SamplingMode = 'Sample based';
elems(4).Min = [];
elems(4).Max = [];

elems(5) = Simulink.BusElement;
elems(5).Name = 'dh_ftps_max';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).SamplingMode = 'Sample based';
elems(5).Min = [];
elems(5).Max = [];

elems(6) = Simulink.BusElement;
elems(6).Name = 'dh_ftps_min';
elems(6).Dimensions = 1;
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).SampleTime = -1;
elems(6).Complexity = 'real';
elems(6).SamplingMode = 'Sample based';
elems(6).Min = [];
elems(6).Max = [];

elems(7) = Simulink.BusElement;
elems(7).Name = 'q_radps_max';
elems(7).Dimensions = 1;
elems(7).DimensionsMode = 'Fixed';
elems(7).DataType = 'double';
elems(7).SampleTime = -1;
elems(7).Complexity = 'real';
elems(7).SamplingMode = 'Sample based';
elems(7).Min = [];
elems(7).Max = [];

elems(8) = Simulink.BusElement;
elems(8).Name = 'phi_rad_max';
elems(8).Dimensions = 1;
elems(8).DimensionsMode = 'Fixed';
elems(8).DataType = 'double';
elems(8).SampleTime = -1;
elems(8).Complexity = 'real';
elems(8).SamplingMode = 'Sample based';
elems(8).Min = [];
elems(8).Max = [];

elems(9) = Simulink.BusElement;
elems(9).Name = 'dphi_radps_max';
elems(9).Dimensions = 1;
elems(9).DimensionsMode = 'Fixed';
elems(9).DataType = 'double';
elems(9).SampleTime = -1;
elems(9).Complexity = 'real';
elems(9).SamplingMode = 'Sample based';
elems(9).Min = [];
elems(9).Max = [];

elems(10) = Simulink.BusElement;
elems(10).Name = 'r_radps_max';
elems(10).Dimensions = 1;
elems(10).DimensionsMode = 'Fixed';
elems(10).DataType = 'double';
elems(10).SampleTime = -1;
elems(10).Complexity = 'real';
elems(10).SamplingMode = 'Sample based';
elems(10).Min = [];
elems(10).Max = [];

elems(11) = Simulink.BusElement;
elems(11).Name = 'pNUM';
elems(11).Dimensions = [2;1];
elems(11).DimensionsMode = 'Fixed';
elems(11).DataType = 'double';
elems(11).SampleTime = -1;
elems(11).Complexity = 'real';
elems(11).SamplingMode = 'Sample based';
elems(11).Min = [];
elems(11).Max = [];

elems(12) = Simulink.BusElement;
elems(12).Name = 'pDEN';
elems(12).Dimensions = 1;
elems(12).DimensionsMode = 'Fixed';
elems(12).DataType = 'double';
elems(12).SampleTime = -1;
elems(12).Complexity = 'real';
elems(12).SamplingMode = 'Sample based';
elems(12).Min = [];
elems(12).Max = [];

elems(13) = Simulink.BusElement;
elems(13).Name = 'hNUM';
elems(13).Dimensions = [2;1];
elems(13).DimensionsMode = 'Fixed';
elems(13).DataType = 'double';
elems(13).SampleTime = -1;
elems(13).Complexity = 'real';
elems(13).SamplingMode = 'Sample based';
elems(13).Min = [];
elems(13).Max = [];

elems(14) = Simulink.BusElement;
elems(14).Name = 'hDEN';
elems(14).Dimensions = 1;
elems(14).DimensionsMode = 'Fixed';
elems(14).DataType = 'double';
elems(14).SampleTime = -1;
elems(14).Complexity = 'real';
elems(14).SamplingMode = 'Sample based';
elems(14).Min = [];
elems(14).Max = [];

elems(15) = Simulink.BusElement;
elems(15).Name = 'rNUM';
elems(15).Dimensions = [2;1];
elems(15).DimensionsMode = 'Fixed';
elems(15).DataType = 'double';
elems(15).SampleTime = -1;
elems(15).Complexity = 'real';
elems(15).SamplingMode = 'Sample based';
elems(15).Min = [];
elems(15).Max = [];

elems(16) = Simulink.BusElement;
elems(16).Name = 'rDEN';
elems(16).Dimensions = 1;
elems(16).DimensionsMode = 'Fixed';
elems(16).DataType = 'double';
elems(16).SampleTime = -1;
elems(16).Complexity = 'real';
elems(16).SamplingMode = 'Sample based';
elems(16).Min = [];
elems(16).Max = [];

AircraftConstraints = Simulink.Bus;
AircraftConstraints.HeaderFile = '';
AircraftConstraints.Description = sprintf('');
AircraftConstraints.DataScope = 'Auto';
AircraftConstraints.Alignment = -1;
AircraftConstraints.Elements = elems;
assigninContext('AircraftConstraints', AircraftConstraints)

%--------------------------------------------------------------------------
% Bus object: AircraftEncounterModelEvents
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'dh_ftps';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).SamplingMode = 'Sample based';
elems(1).Min = [];
elems(1).Max = [];

elems(2) = Simulink.BusElement;
elems(2).Name = 'dpsi_radps';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).SamplingMode = 'Sample based';
elems(2).Min = [];
elems(2).Max = [];

elems(3) = Simulink.BusElement;
elems(3).Name = 'dv_ftpss';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).SamplingMode = 'Sample based';
elems(3).Min = [];
elems(3).Max = [];

AircraftEncounterModelEvents = Simulink.Bus;
AircraftEncounterModelEvents.HeaderFile = '';
AircraftEncounterModelEvents.Description = sprintf('');
AircraftEncounterModelEvents.DataScope = 'Auto';
AircraftEncounterModelEvents.Alignment = -1;
AircraftEncounterModelEvents.Elements = elems;
assigninContext('AircraftEncounterModelEvents', AircraftEncounterModelEvents)

%--------------------------------------------------------------------------
% Bus object: AdsbSurveillance
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'position';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'Bus: LatLonAltMeasurement';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).SamplingMode = 'Sample based';
elems(1).Min = [];
elems(1).Max = [];

elems(2) = Simulink.BusElement;
elems(2).Name = 'isValid';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'boolean';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).SamplingMode = 'Sample based';
elems(2).Min = [];
elems(2).Max = [];

elems(3) = Simulink.BusElement;
elems(3).Name = 'timeOfValidity';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).SamplingMode = 'Sample based';
elems(3).Min = [];
elems(3).Max = [];

AdsbSurveillance = Simulink.Bus;
AdsbSurveillance.HeaderFile = '';
AdsbSurveillance.Description = sprintf('');
AdsbSurveillance.DataScope = 'Auto';
AdsbSurveillance.Alignment = -1;
AdsbSurveillance.Elements = elems;
assigninContext('AdsbSurveillance', AdsbSurveillance)

%--------------------------------------------------------------------------
% Bus object: TcasSurveillance
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'isValid';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'boolean';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).SamplingMode = 'Sample based';
elems(1).Min = [];
elems(1).Max = [];

elems(2) = Simulink.BusElement;
elems(2).Name = 'timeOfValidity';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).SamplingMode = 'Sample based';
elems(2).Min = [];
elems(2).Max = [];

elems(3) = Simulink.BusElement;
elems(3).Name = 'intruderBearing_rad';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).SamplingMode = 'Sample based';
elems(3).Min = [];
elems(3).Max = [];

elems(4) = Simulink.BusElement;
elems(4).Name = 'intruderRange_ft';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).SamplingMode = 'Sample based';
elems(4).Min = [];
elems(4).Max = [];

elems(5) = Simulink.BusElement;
elems(5).Name = 'intruderQuantizedAltitude_ft';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).SamplingMode = 'Sample based';
elems(5).Min = [];
elems(5).Max = [];

elems(6) = Simulink.BusElement;
elems(6).Name = 'intruderAltimeterEncoding_ft';
elems(6).Dimensions = 1;
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).SampleTime = -1;
elems(6).Complexity = 'real';
elems(6).SamplingMode = 'Sample based';
elems(6).Min = [];
elems(6).Max = [];

elems(7) = Simulink.BusElement;
elems(7).Name = 'ownshipAltitude_ft';
elems(7).Dimensions = 1;
elems(7).DimensionsMode = 'Fixed';
elems(7).DataType = 'double';
elems(7).SampleTime = -1;
elems(7).Complexity = 'real';
elems(7).SamplingMode = 'Sample based';
elems(7).Min = [];
elems(7).Max = [];

elems(8) = Simulink.BusElement;
elems(8).Name = 'ownshipRadarAltitude_ft';
elems(8).Dimensions = 1;
elems(8).DimensionsMode = 'Fixed';
elems(8).DataType = 'double';
elems(8).SampleTime = -1;
elems(8).Complexity = 'real';
elems(8).SamplingMode = 'Sample based';
elems(8).Min = [];
elems(8).Max = [];

TcasSurveillance = Simulink.Bus;
TcasSurveillance.HeaderFile = '';
TcasSurveillance.Description = sprintf('');
TcasSurveillance.DataScope = 'Auto';
TcasSurveillance.Alignment = -1;
TcasSurveillance.Elements = elems;
assigninContext('TcasSurveillance', TcasSurveillance)

%--------------------------------------------------------------------------
% Bus object: AircraftStateRate 
clear elems;
elems(1) = Simulink.BusElement;
elems(1).Name = 'vdot_fpss';
elems(1).Dimensions = 1;
elems(1).DimensionsMode = 'Fixed';
elems(1).DataType = 'double';
elems(1).SampleTime = -1;
elems(1).Complexity = 'real';
elems(1).SamplingMode = 'Sample based';
elems(1).Min = [];
elems(1).Max = [];
elems(1).DocUnits = sprintf('');
elems(1).Description = sprintf('');

elems(2) = Simulink.BusElement;
elems(2).Name = 'Ndot_ftps';
elems(2).Dimensions = 1;
elems(2).DimensionsMode = 'Fixed';
elems(2).DataType = 'double';
elems(2).SampleTime = -1;
elems(2).Complexity = 'real';
elems(2).SamplingMode = 'Sample based';
elems(2).Min = [];
elems(2).Max = [];
elems(2).DocUnits = sprintf('');
elems(2).Description = sprintf('');

elems(3) = Simulink.BusElement;
elems(3).Name = 'Edot_ftps';
elems(3).Dimensions = 1;
elems(3).DimensionsMode = 'Fixed';
elems(3).DataType = 'double';
elems(3).SampleTime = -1;
elems(3).Complexity = 'real';
elems(3).SamplingMode = 'Sample based';
elems(3).Min = [];
elems(3).Max = [];
elems(3).DocUnits = sprintf('');
elems(3).Description = sprintf('');

elems(4) = Simulink.BusElement;
elems(4).Name = 'hdot_ftps';
elems(4).Dimensions = 1;
elems(4).DimensionsMode = 'Fixed';
elems(4).DataType = 'double';
elems(4).SampleTime = -1;
elems(4).Complexity = 'real';
elems(4).SamplingMode = 'Sample based';
elems(4).Min = [];
elems(4).Max = [];
elems(4).DocUnits = sprintf('');
elems(4).Description = sprintf('');

elems(5) = Simulink.BusElement;
elems(5).Name = 'psidot_radps';
elems(5).Dimensions = 1;
elems(5).DimensionsMode = 'Fixed';
elems(5).DataType = 'double';
elems(5).SampleTime = -1;
elems(5).Complexity = 'real';
elems(5).SamplingMode = 'Sample based';
elems(5).Min = [];
elems(5).Max = [];
elems(5).DocUnits = sprintf('');
elems(5).Description = sprintf('');

elems(6) = Simulink.BusElement;
elems(6).Name = 'thetadot_radps';
elems(6).Dimensions = 1;
elems(6).DimensionsMode = 'Fixed';
elems(6).DataType = 'double';
elems(6).SampleTime = -1;
elems(6).Complexity = 'real';
elems(6).SamplingMode = 'Sample based';
elems(6).Min = [];
elems(6).Max = [];
elems(6).DocUnits = sprintf('');
elems(6).Description = sprintf('');

elems(7) = Simulink.BusElement;
elems(7).Name = 'phidot_radps';
elems(7).Dimensions = 1;
elems(7).DimensionsMode = 'Fixed';
elems(7).DataType = 'double';
elems(7).SampleTime = -1;
elems(7).Complexity = 'real';
elems(7).SamplingMode = 'Sample based';
elems(7).Min = [];
elems(7).Max = [];
elems(7).DocUnits = sprintf('');
elems(7).Description = sprintf('');

AircraftStateRate = Simulink.Bus;
AircraftStateRate.HeaderFile = '';
AircraftStateRate.Description = sprintf('');
AircraftStateRate.DataScope = 'Auto';
AircraftStateRate.Alignment = -1;
AircraftStateRate.Elements = elems;
assigninContext('AircraftStateRate', AircraftStateRate)
