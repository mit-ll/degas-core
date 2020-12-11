classdef AircraftStateBusReader
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% AircraftStateBusReader: Used to interpret the output from a 
% AircraftState bus at the top level of a Simulink model

    properties(Constant=true,Access=private)
        busInfo = BusInformation( evalin('base','AircraftState') ); 
        % NOTE: evalin gets Simulink.Bus object from base workspace
    end
    properties(Constant=true)
        % The number of scalar values contained on the bus.  This is 
        % generally not equal to the number of elements in the bus.  
        width = AircraftStateBusReader.busInfo.width;
    end

    methods
        function this = AircraftStateBusReader( signals )
        % Interpret a matrix as a flattened AircraftStateBus 
        % signals is an N x (AircraftStateBusReader.width) double matrix of
        % outputs from an AircraftState bus
            
            assert( size( signals, 2 ) == AircraftStateBusReader.width );
            
            this.matrix_data_ = signals;
        end
    end
    
    properties(Access=private)
        matrix_data_
    end
    
    properties(Dependent = true)
        latLonAltState
        v_ftps
        n_ft
        e_ft
        h_ft
        psi_rad
        theta_rad
        phi_rad
        p_radps
        q_radps
        r_radps
        dv_ftps2
        dh_ftps
        ddh_ftps2
    end
    
    methods
        function value = get.latLonAltState( this )
            value = LatLonAltMeasurementBusReader( this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('latLonAltState') ) );
        end
        function value = get.v_ftps( this )
            value = this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('v_ftps'));
        end
        function value = get.n_ft( this )
            value = this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('n_ft'));
        end
        function value = get.e_ft( this )
            value = this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('e_ft'));
        end
        function value = get.h_ft( this )
            value = this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('h_ft'));
        end
        function value = get.psi_rad( this )
            value = this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('psi_rad'));
        end
        function value = get.theta_rad( this )
            value = this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('theta_rad'));
        end
        function value = get.phi_rad( this )
            value = this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('phi_rad'));
        end
        function value = get.p_radps( this )
            value = this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('p_radps'));
        end
        function value = get.q_radps( this )
            value = this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('q_radps'));
        end
        function value = get.r_radps( this )
            value = this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('r_radps'));
        end
        function value = get.dv_ftps2( this )
            value = this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('dv_ftps2'));
        end
        function value = get.dh_ftps( this )
            value = this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('dh_ftps'));
        end
        function value = get.ddh_ftps2( this )
            value = this.matrix_data_(:,AircraftStateBusReader.busInfo.getFlattenedLocation('ddh_ftps2'));
        end        
    end
    
end