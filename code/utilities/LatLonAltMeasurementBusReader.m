classdef LatLonAltMeasurementBusReader
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% LatLonAltMeasurementBusReader: Used to interpret the output from a 
% LatLonAltMeasurement bus at the top level of a Simulink model


    properties(Constant=true,Access=private)
        busInfo = BusInformation( evalin('base','LatLonAltMeasurement') ); 
        % NOTE: evalin gets Simulink.Bus object from base workspace
    end
    properties(Constant=true)
        % The number of scalar values contained on the bus.  This is 
        % generally not equal to the number of elements in the bus.  
        width = LatLonAltMeasurementBusReader.busInfo.width;
    end

    methods
        function this = LatLonAltMeasurementBusReader( signals )
        % Interpret a matrix as a flattened LatLonAltMeasurement bus 
        % signals is an N x (LatLonAltMeasurementBusReader.width) double 
        % matrix of outputs from an LatLonAltMeasurement bus
            
            assert( size( signals, 2 ) == LatLonAltMeasurementBusReader.width );
            
            this.matrix_data_ = signals;
        end
    end
    
    properties(Access=private)
        matrix_data_
    end
    
    properties(Dependent = true)
        lat_rad
        lon_rad
        dlat_radps
        dlon_radps
        alt_ft
        dalt_ftps
    end
    
    methods
        function value = get.lat_rad( this )
            value = this.matrix_data_(:,LatLonAltMeasurementBusReader.busInfo.getFlattenedLocation('lat_rad'));
        end
        function value = get.lon_rad( this )
            value = this.matrix_data_(:,LatLonAltMeasurementBusReader.busInfo.getFlattenedLocation('lon_rad'));
        end
        function value = get.dlat_radps( this )
            value = this.matrix_data_(:,LatLonAltMeasurementBusReader.busInfo.getFlattenedLocation('dlat_radps'));
        end
        function value = get.dlon_radps( this )
            value = this.matrix_data_(:,LatLonAltMeasurementBusReader.busInfo.getFlattenedLocation('dlon_radps'));
        end
        function value = get.alt_ft( this )
            value = this.matrix_data_(:,LatLonAltMeasurementBusReader.busInfo.getFlattenedLocation('alt_ft'));
        end
        function value = get.dalt_ftps( this )
            value = this.matrix_data_(:,LatLonAltMeasurementBusReader.busInfo.getFlattenedLocation('dalt_ftps'));
        end
    end
    
end