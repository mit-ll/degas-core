classdef CommonMetrics < MetricBlock
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
%COMMONMETRICS Wrapper class used to read the metrics calculated in
%DEGAS v1 block Common Metrics
    
    properties (GetAccess=public, SetAccess=private)
        nmac % Near Mid Air Collision.  True if the separation between the two  
             %     aircraft has ever been simultaneously less than 100 feet vertically and 
             %     500 feet horizontally.
        hmd_ft % Horizontal Miss Distance in feet.  The horizontal separation of the
             %     two aircraft at the Time of Closest Approach.
        vmd_ft % Vertical Miss Distance in feet.  The vertical separation of the 
             %     two aircraft at the Time of Closest Approach.
        tca % Time of Closest Approach in seconds.  Prior to horizontal separation 
             %     of less than 500 feet, the Time of Closest Approach is the time when 
             %     the minimum horizontal separation was achieved.  Once horizontal 
             %     separation has been less than 500 feet, the Time of Closest Approach is 
             %     when minimum vertical separation occurs while horizontal separation is 
             %     less than 500 feet. 
        hmd_mhd_ft % Horizontal Miss Distance at the time of minimum horizontal separation
        vmd_mhd_ft % Vertical Miss Distance at the time of minimum horizontal separation
        tca_mhd % Time of minimum horizontal separation
        pNMAC % Probability of NMAC. Probability that an NMAC actually occurred 
             %     given horizontal and vertical separation of the two
             %     aircraft. An NMAC may or may not occur when the measured 
             %     separation between the two aircraft is simultaneously less 
             %     than 100 feet vertically and 500 feet horizontally due
             %     to altimetry error.        
        
        min_hsep_ft % Minimum horizontal separation between the two aircraft
        min_vsep_ft % Minimum vertical separation between the two aircraft
        min_slantRange_ft % Minimum distance between the two aircraft
        
        Tend % Time at which the simulation terminated
             
    end
    
    methods
        function this = CommonMetrics( simObj )
            this = this@MetricBlock( simObj );
        end
    end
    
    methods
        function onSimulationComplete( this, simObj ) % Handler on Output objects that should be called after the simulation is run       
            this.nmac = simObj.readFromWorkspace( 'NMAC' );
            this.hmd_ft = simObj.readFromWorkspace( 'hmd_ft' );
            this.vmd_ft = simObj.readFromWorkspace( 'vmd_ft' );
            this.tca = simObj.readFromWorkspace( 'tca' );               
  
            this.min_hsep_ft = simObj.readFromWorkspace( 'min_hsep_ft' );
            this.min_vsep_ft = simObj.readFromWorkspace( 'min_vsep_ft' );
            this.min_slantRange_ft = simObj.readFromWorkspace( 'min_slantRange_ft' );
            
            this.hmd_mhd_ft = simObj.readFromWorkspace( 'hmd_mhd_ft' );
            this.vmd_mhd_ft = simObj.readFromWorkspace( 'vmd_mhd_ft' );
            this.tca_mhd = simObj.readFromWorkspace( 'tca_mhd' );            
            
            this.Tend = simObj.readFromWorkspace( 'Tend' );
            
            %Check whether transponder properties exist
            %Assume that simulations that wish to compute pNMAC will have a
            %Transponder1 and Transponder2 property.
            err = [];
            try
                % Altitude at CPA
                alt_at_CPA = 0.5*(simObj.readFromWorkspace('own_h_at_tca') + simObj.readFromWorkspace('int_h_at_tca'));
                
                transponder1 = simObj.ac1Transponder;
                transponder2 = simObj.ac2Transponder;
                
                equipage_ac1 = transponder1.equippage;
                equipage_ac2 = transponder2.equippage;
                
                model = transponder1.model;
                alterr = transponder1.alterr;
                
            catch err
                
            end
            
            if ( isempty( err ) )
                %If they exist, compute p(NMAC) considering altimetry error
                this.pNMAC = this.compute_pNMAC(this.hmd_ft, this.vmd_ft, equipage_ac1, equipage_ac2, alt_at_CPA, alterr, model);
            end
            
            % Pass the message on to any child objects
            onSimulationComplete@DEGAS( this, simObj );
        end
    end
    
    methods
        function metricStruct = addMetrics( this, metricStruct ) 
            % Add the metrics of this block as new fields to the provided structure

            metricStruct.nmac = this.nmac;
            metricStruct.hmd_ft = this.hmd_ft;
            metricStruct.vmd_ft = this.vmd_ft;
            metricStruct.tca = this.tca;
            metricStruct.hmd_mhd_ft = this.hmd_mhd_ft;
            metricStruct.vmd_mhd_ft = this.vmd_mhd_ft;
            metricStruct.tca_mhd = this.tca_mhd;
            metricStruct.pNMAC = this.pNMAC;
            metricStruct.min_hsep_ft = this.min_hsep_ft;
            metricStruct.min_vsep_ft = this.min_vsep_ft;
            metricStruct.min_slantRange_ft = this.min_slantRange_ft;
            metricStruct.Tend = this.Tend;
        end
        %Function to compute post altimetry error
        function pNMAC = compute_pNMAC(this, hsep_ft, vsep_ft, equipage_ac1, equipage_ac2, own_h, alterr, model)
            % computes pNMAC given horizontal/vertical separation information while
            % considering altimetry error

%             %Equipage information is part of aircraft crosslink
%             equipage_ac1 = ownshipCrosslink.equippage;
%             equipage_ac2 = intruderCrosslink.equippage;

            % Initialization logic
            if( hsep_ft < 500 )
                horizontal_p = 1;
            else
                horizontal_p = 0; %An NMAC could not have occurred
            end

            if(alterr == 0) %use 'post' altimetry error
                % Regular logic
                alt_quality = zeros(1,2);
                if (equipage_ac1 == 0 || equipage_ac1 == 1)
                    alt_quality(1) = 0;
                else
                    alt_quality(1) = 1;
                end
                if (equipage_ac2 == 0 || equipage_ac2 == 1)
                    alt_quality(2) = 0;
                else
                    alt_quality(2) = 1;
                end

                current_alt = own_h;
                if     (current_alt > 41000); lam1 = 94; lam2 = 101;  p1 = 0.610;
                elseif (current_alt > 20000); lam1 = 72; lam2 = 101;  p1 = 0.610;
                elseif (current_alt > 10000); lam1 = 58; lam2 = 87;   p1 = 0.610;
                elseif (current_alt > 5000);  lam1 = 43; lam2 = 69;   p1 = 0.345;
                elseif (current_alt > 2300);  lam1 = 38; lam2 = 60;   p1 = 0.320;
                else                          lam1 = 35; lam2 = 60;   p1 = 0.391;
                end

                % find probability of NMAC
                % limits of integration are the separation +/- 100 ft
                if (alt_quality(1) == 1 && alt_quality(2) == 1)
                    %Parameters For the European Model
                    %For encounters in which one of the aircraft is unequipped,
                    %the European model and the ICAO model are the same.
                    if (model == 0)
                        lam1 = 35;
                    end
                    p = this.NMAC_prob(-vsep_ft-100, -vsep_ft+100, [lam1, lam1]);
                elseif (alt_quality(1) == 1 && alt_quality(2) == 0)
                    p = p1*this.NMAC_prob(-vsep_ft-100, -vsep_ft+100, [lam1, lam1]) + ...
                        (1-p1)*this.NMAC_prob(-vsep_ft-100, -vsep_ft+100, [lam1, lam2]);
                elseif (alt_quality(1) == 0 && alt_quality(2) == 1)
                    p = p1*this.NMAC_prob(-vsep_ft-100, -vsep_ft+100, [lam1, lam1]) + ...
                        (1-p1)*this.NMAC_prob(-vsep_ft-100, -vsep_ft+100, [lam2, lam1]);
                else
                    p = p1*p1*this.NMAC_prob(-vsep_ft-100, -vsep_ft+100, [lam1, lam1]) + ...
                        (1-p1)*(1-p1)*this.NMAC_prob(-vsep_ft-100, -vsep_ft+100, [lam2, lam2])+...
                        p1*(1-p1)*this.NMAC_prob(-vsep_ft-100, -vsep_ft+100, [lam1, lam2])+...
                        (1-p1)*p1*this.NMAC_prob(-vsep_ft-100, -vsep_ft+100, [lam2, lam1]);
                end
            else
                if (abs(vsep_ft) <= 100)
                    p = 1;
                else
                    p = 0;
                end
            end

            pNMAC = horizontal_p*p;
        end

        function p = NMAC_prob(this, a, b, lam)
            % based on ACASA WP 036
            % (a,b) are limits of integration for the pdfs.
            % lam(2) has the alt error coefficients for each aircraft

            % use altimetry error model to compute probability of NMAC
            % find altitude error model parameters (ICAO model)

            if (lam(1) == lam(2))
                if (a < 0 && b < 0)
                    p = 1/4*(exp(b/lam(1))*(2-b/lam(1)) - exp(a/lam(1))*(2-a/lam(1)));
                elseif (a < 0 && b >= 0)
                    p = 1 + exp(a/lam(1))*(-1/4+1/4*(a/lam(1)-1)) + exp(-b/lam(1))*(-1/4+1/4*(-b/lam(1)-1));
                else
                    p = exp(-a/lam(1))*(1/2+1/4*a/lam(1)) + exp(-b/lam(1))*(-1/2-1/4*b/lam(1));
                end
            else
                lam1s = lam(1)*lam(1); lam2s = lam(2)*lam(2);
                if (a < 0 && b < 0)
                    p = 1/(2*(lam1s-lam2s))*(lam1s*(exp(b/lam(1))-exp(a/lam(1))) -...
                                             lam2s*(exp(b/lam(2))-exp(a/lam(2))));
                elseif (a < 0 && b >= 0)        
                    p = 1/(2*(lam1s-lam2s))*(2*(lam1s-lam2s)-lam1s*(exp(a/lam(1))+exp(-b/lam(1)))+...
                                                             lam2s*(exp(a/lam(2))+exp(-b/lam(2))));
                else
                    p = 1/(2*(lam1s-lam2s))*(-lam1s*(exp(-b/lam(1))-exp(-a/lam(1)))+...
                                              lam2s*(exp(-b/lam(2))-exp(-a/lam(2))));
                end
            end
        end               
    end
    
    
end