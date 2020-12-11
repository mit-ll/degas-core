classdef AircraftEstimateBusReader
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% AircraftEstimateBusReader: Used to interpret the output from a 
% AircraftEstimate bus at the top level of a Simulink model

    properties(Constant=true,Access=private)
        busInfo = BusInformation( evalin('base','AircraftEstimate') ); 
        % NOTE: evalin gets Simulink.Bus object from base workspace
    end
    properties(Constant=true)
        % The number of scalar values contained on the bus.  This is 
        % generally not equal to the number of elements in the bus.  
        width = AircraftEstimateBusReader.busInfo.width;
    end
    methods
        function this = AircraftEstimateBusReader( signals )
        % Interpret a matrix as a flattened AircraftEstimateBus 
        % signals is an N x (AircraftEstimateBusReader.width) double matrix
        % of outputs from an AircraftEstimate bus
            
            assert( size( signals, 2 ) == AircraftEstimateBusReader.width );
            
            this.matrix_data_ = signals;
        end
    end
    
    properties(Access=private)
        matrix_data_
    end
    
    properties(Dependent = true)
        latLonAltEst
        timeOfValidity
        isValid
        enuStateEstimate
        covEstimate
    end
    
    methods
        function value = get.latLonAltEst( this )
            value = LatLonAltMeasurementBusReader( this.matrix_data_(:,AircraftEstimateBusReader.busInfo.getFlattenedLocation('latLonAltEst') ) );
        end
        function value = get.timeOfValidity( this )
            value = this.matrix_data_(:,AircraftEstimateBusReader.busInfo.getFlattenedLocation('timeOfValidity'));
        end
        function value = get.isValid( this )
            value = this.matrix_data_(:,AircraftEstimateBusReader.busInfo.getFlattenedLocation('isValid'));
        end
        function value = get.enuStateEstimate( this )
            temp = this.matrix_data_(:,AircraftEstimateBusReader.busInfo.getFlattenedLocation('enuStateEstimate'));
            value.n_ft = temp(:,1);
            value.e_ft = temp(:,2);
            value.h_ft = temp(:,3);
            value.dn_ftps = temp(:,4);
            value.de_ftps = temp(:,5);
            value.dh_ftps = temp(:,6);
        end
        function value = get.covEstimate( this )
            temp = this.matrix_data_(:,AircraftEstimateBusReader.busInfo.getFlattenedLocation('covEstimate'));
            value.nVar_ft2 = temp(:,1);
            value.eVar_ft2 = temp(:,2);
            value.hVar_ft2 = temp(:,3);
            value.dnVar_ft2ps2 = temp(:,4);
            value.deVar_ft2ps2 = temp(:,5);
            value.dgVar_ft2ps2 = temp(:,6);
        end        
    end
    
end