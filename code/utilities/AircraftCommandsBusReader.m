classdef AircraftCommandsBusReader
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% AircraftCommandsBusReader: Used to interpret the output from a 
% AircraftCommands bus at the top level of a Simulink model

    properties(Constant=true,Access=private)
        busInfo = BusInformation( evalin('base','AircraftCommands') ); 
        % NOTE: evalin gets Simulink.Bus object from base workspace
    end
    properties(Constant=true)
        % The number of scalar values contained on the bus.  This is 
        % generally not equal to the number of elements in the bus.  
        width = AircraftCommandsBusReader.busInfo.width;
    end

    methods
        function this = AircraftCommandsBusReader( signals )
        % Interpret a matrix as a flattened AircraftCommands bus
        % signals is an N x (AircraftCommandsBusReader.width) double 
        % matrix of outputs from an AircraftCommands bus
            
            assert( size( signals, 2 ) == AircraftCommandsBusReader.width );
            
            this.matrix_data_ = signals;
        end
    end
    
    properties(Access=private)
        matrix_data_
    end
    
    properties(Dependent = true)
        h_flag
        h_ft
        v_flag
        v_ftps
        phi_flag
        phi_rad
        dh_flag
        dh_ftps
        dv_flag
        dv_ftps2
        dpsi_flag
        dpsi_radps
        ddh_flag
        ddh_ftps2
        theta_flag
        theta_rad
        ddz_flag
        ddz_ftps2
    end
    
    methods
        function value = get.h_flag( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('h_flag'));
        end
        function value = get.h_ft( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('h_ft'));
        end
        function value = get.v_flag( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('v_flag'));
        end
        function value = get.v_ftps( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('v_ftps'));
        end
        function value = get.phi_flag( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('phi_flag'));
        end
        function value = get.phi_rad( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('phi_rad'));
        end
        function value = get.dh_flag( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('dh_flag'));
        end
        function value = get.dh_ftps( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('dh_ftps'));
        end
        function value = get.dv_flag( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('dv_flag'));
        end
        function value = get.dv_ftps2( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('dv_ftps2'));
        end
        function value = get.dpsi_flag( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('dpsi_flag'));
        end
        function value = get.dpsi_radps( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('dpsi_radps'));
        end
        function value = get.ddh_flag( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('ddh_flag'));
        end
        function value = get.ddh_ftps2( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('ddh_ftps2'));
        end
        function value = get.theta_flag( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('theta_flag'));
        end
        function value = get.theta_rad( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('theta_rad'));
        end
        function value = get.ddz_flag( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('ddz_flag'));
        end
        function value = get.ddz_ftps2( this )
            value = this.matrix_data_(:,AircraftCommandsBusReader.busInfo.getFlattenedLocation('ddz_ftps2'));
        end
    end
    
end
