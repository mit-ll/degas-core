classdef AircraftStateRateBusReader
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% AircraftStateRateBusReader: Used to interpret the output from a 
% AircraftStateRate bus at the top level of a Simulink model

    properties(Constant=true,Access=private)
        busInfo = BusInformation( evalin('base','AircraftStateRate') ); 
        % NOTE: evalin gets Simulink.Bus object from base workspace
    end
    properties(Constant=true,Hidden=true)
        % The number of scalar values contained on the bus.  This is 
        % generally not equal to the number of elements in the bus.  
        width = AircraftStateRateBusReader.busInfo.width;
    end

    methods
        function this = AircraftStateRateBusReader( signals )
        % Interpret a matrix as a flattened AircraftStateRateBus 
        % signals is an N x (AircraftStateRateBusReader.width) double 
        % matrix of outputs from an AircraftStateRate bus
            
            assert( size( signals, 2 ) == AircraftStateRateBusReader.width );
            
            this.matrix_data_ = signals;
        end
    end
    
    properties(Access=private)
        matrix_data_
    end
    
    properties(Dependent = true)
        vdot_ftpss
        Ndot_ftps
        Edot_ftps
        hdot_ftps
        psidot_radps
        thetadot_radps
        phidot_radps
    end
    
    methods
        function value = get.vdot_ftpss( this )
            value = this.matrix_data_(:,AircraftStateRateBusReader.busInfo.getFlattenedLocation('vdot_fpss'));
        end
        function value = get.Ndot_ftps( this )
            value = this.matrix_data_(:,AircraftStateRateBusReader.busInfo.getFlattenedLocation('Ndot_ftps'));
        end
        function value = get.Edot_ftps( this )
            value = this.matrix_data_(:,AircraftStateRateBusReader.busInfo.getFlattenedLocation('Edot_ftps'));
        end
        function value = get.hdot_ftps( this )
            value = this.matrix_data_(:,AircraftStateRateBusReader.busInfo.getFlattenedLocation('hdot_ftps'));
        end
        function value = get.psidot_radps( this )
            value = this.matrix_data_(:,AircraftStateRateBusReader.busInfo.getFlattenedLocation('psidot_radps'));
        end
        function value = get.thetadot_radps( this )
            value = this.matrix_data_(:,AircraftStateRateBusReader.busInfo.getFlattenedLocation('thetadot_radps'));
        end
        function value = get.phidot_radps( this )
            value = this.matrix_data_(:,AircraftStateRateBusReader.busInfo.getFlattenedLocation('phidot_radps'));
        end
    end
    
end