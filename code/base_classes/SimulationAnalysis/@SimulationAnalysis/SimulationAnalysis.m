classdef SimulationAnalysis
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% SimulationAnalysis: The SimulationAnalysis class contains methods for 
% examining the results of a simulation.

	methods
        function this = SimulationAnalysis( theSim )
            assert( isa( theSim, 'Simulation' ), 'Argument to constructor of SimulationAnalysis must be a Simulation object' );
            this.theSim = theSim;
        end
    end
    
    properties(Dependent=true)
        horizontalSeparation_ft % Horizontal seperation between both aircraft in ft.
        verticalSeparation_ft % Vertical seperation between both aircraft in ft.
        slantRange_ft % 3D Slant range in ft.
        rangeRate_ftps % Range rate between both aircraft in feet per second
        time_sec % Simulation time in seconds
    end    
    
    properties(Access=private)
        theSim
    end
    methods
        function v = get.horizontalSeparation_ft( this )
            assert( all( this.theSim.results(1).time == this.theSim.results(2).time ) )
            v = sqrt( (this.theSim.results(1).east_ft - this.theSim.results(2).east_ft).^2 + ...
                      (this.theSim.results(1).north_ft - this.theSim.results(2).north_ft).^2 );
        end
        function v = get.verticalSeparation_ft( this )
            assert( all( this.theSim.results(1).time == this.theSim.results(2).time ) )
            v = this.theSim.results(2).up_ft - this.theSim.results(1).up_ft;
        end
        function v = get.time_sec( this )
            assert( all( this.theSim.results(1).time == this.theSim.results(2).time ) )
            v = this.theSim.results(1).time;
        end
        function v = get.slantRange_ft( this )
            v = sqrt( (this.horizontalSeparation_ft).^2 + (this.verticalSeparation_ft).^2 );
        end
        function v = get.rangeRate_ftps( this )
            relVelNED_ftps = [ this.theSim.results(2).Ndot_ftps(:)-this.theSim.results(1).Ndot_ftps(:) this.theSim.results(2).Edot_ftps(:)-this.theSim.results(1).Edot_ftps(:) this.theSim.results(1).hdot_ftps(:)-this.theSim.results(2).hdot_ftps(:) ];
            rhat_ned = [ this.theSim.results(2).north_ft(:)- this.theSim.results(1).north_ft(:), ...
                         this.theSim.results(2).east_ft(:) - this.theSim.results(1).east_ft(:), ...
                         this.theSim.results(1).up_ft(:)   - this.theSim.results(2).up_ft(:) ];
            rmag = sqrt( sum( rhat_ned.^2, 2 ) );
            rhat_ned = rhat_ned ./ repmat( rmag, 1, 3 );
            v = sum( relVelNED_ftps.*rhat_ned, 2 );
        end
    end
    
    methods
        function plotSeparation( this )
            subplot( 2, 1, 1 )           
            plot( this.time_sec, this.verticalSeparation_ft );
            ylabel( 'Vertical Separation (ft)' )
            b = axis();
            hold on
            plot( [ b(1) b(2) ], -100*[ 1 1 ], 'c' );
            plot( [ b(1) b(2) ],  100*[ 1 1 ], 'c' );
            plot( [ b(1) b(2) ], -1000*[ 1 1 ], 'c' );
            plot( [ b(1) b(2) ],  1000*[ 1 1 ], 'c' );
            
            
            subplot( 2, 1, 2 )
            plot( this.time_sec, this.horizontalSeparation_ft );
            ylabel( 'Horizontal Separation (ft)' );
            b = axis();
            hold on
            plot( [ b(1) b(2) ],  500*[ 1 1 ], 'c' );
            plot( [ b(1) b(2) ],  DEGAS.nm2ft*[ 1 1 ], 'c' );
            
        end
    end
    
end