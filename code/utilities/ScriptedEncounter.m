classdef ScriptedEncounter
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% ScriptedEncounter: An encounter between one or more aircraft
% The initial geometry and subsequent controls of a scripted
% encounter between two or more aircraft
    
    properties
        id
        numberOfAircraft
        
        % Initial quantities - Vectors of length this.numberOfAircraft
        
        v_ftps @double     % Initial true airspeed
        n_ft   @double     % Initial north coordinate
        e_ft   @double     % Initial east coordinate
        h_ft   @double     % Initial altitude AGL
        heading_rad @double% Initial heading, clockwise of True North
        pitch_rad   @double% Initial pitch angle
        bank_rad     @double% Initial bank angle
        a_ftpss     @double% Initial longitudinal acceleration
      
        % Subsequent controls
        
        updates @ EncounterModelEvents % Array of length this.numberOfAircraft of EncounterModelEvents objects
   
        % Metadata
        runTime_s @double; % Duration of encounter
        altLayer @double; % Altitude layer are 500-1200, 1200-3000, 3000-5000, 5000-18000 for uncorrelated model
        
    end
    
    methods
        function this = ScriptedEncounter( id, initial, varargin )
            % Create a new ScriptedEncounter object
            %
            %   this = ScriptedEncounter()
            %   this = ScriptedEncounter( id, initial, updates1, updates2 )
            
            if( nargin > 0 )
                this.id = id;
                this.numberOfAircraft = numel( varargin );
                
                for k = 1 : this.numberOfAircraft
                    this.v_ftps(k) = initial.( [ 'v' num2str(k) '_ftps' ] );
                    this.n_ft(k)   = initial.( [ 'n' num2str(k) '_ft' ] );
                    this.e_ft(k)   = initial.( [ 'e' num2str(k) '_ft' ] );
                    this.h_ft(k)   = initial.( [ 'h' num2str(k) '_ft' ] );
                    this.heading_rad(k)   = initial.( [ 'psi' num2str(k) '_rad' ] );
                    this.pitch_rad(k)   = initial.( [ 'theta' num2str(k) '_rad' ] );
                    this.bank_rad(k)   = initial.( [ 'phi' num2str(k) '_rad' ] );
                    this.a_ftpss(k)    = initial.( [ 'a' num2str(k) '_ftpss' ] );

                    this.updates(k)  = EncounterModelEvents( 'event', varargin{k} );
                end
            end
            
        end
    end
    
    % Useful derived quantities
    properties(Dependent)
        initialHorizontalSeparation_ft
        initialVerticalSeparation_ft
    end
    methods
        function v = get.initialHorizontalSeparation_ft( this )
            v = sqrt( (this.n_ft(2:end) - this.n_ft(1)).^2 + (this.e_ft(2:end) - this.e_ft(1)).^2 );
        end
        function v = get.initialVerticalSeparation_ft( this )
            v = abs( this.h_ft(2:end) - this.h_ft(1) );
        end
    end
    
end

