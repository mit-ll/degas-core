classdef TSAA_Model_External_Functions
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
 
  methods (Static)
    
    function altBias  = degradeAlt(encAlts, acX, lambdaRand, randomValue, usePerfectAltimetry)
      % Altitude Error Model based on ICAO Annex 10 section 4.4.2.4.
      %
      % Assumptions:
      %    - Altitude bias remains the same for a given aircraft throughout the 
      %      duration of the encounter; thus, bias is sampled once at beginning 
      %      of the encounter for each involved aicraft.
      %    - Error distributions are different between ownship and intruder
      %      aircraft, as described in Annex 10.
      %
      % Inputs: 
      %   - encAlt:  Reference altitude used to determine altitude bias for a 
      %              single aircraft. TSAA used the first altitude a flight track
      %              as the reference altitude. Units: FT
      %   - acX:     Aircraft ID; if acX = 1, it is the ownship, if acX /= 1, it
      %              is an intruder aircraft. This is necessary becuase the error
      %              initialization distribution is different between ownship and
      %              intruder aircraft, as described in Annex 10.

      % Outputs:
      %   - altBias:    Altitude Bias. Units: FT
      %

      % REVISIONS
      %  1/29/2013:   Initially completed
      %  11/23/2015:  Improved Documentation

      % Model Configuration

      % Data from ICAO Annex 10, section 4.4.2.4. Columns are "Layer", rows are:
      % lambda1 - lambda value for aircraft carrying ACAS system (ownship)
      % lambda2 - lambda value for intruder aircraft (assumping no ACAS system)
      % prob(lambda1) - 
      % prob(lambda2)
      
      if ~usePerfectAltimetry

        layerData = ...
           [   35,         38,         43,         58,         72,         94;
               60,         60,         69,         87,        101,        101;
            0.391,      0.320,      0.345,      0.610,      0.610,      0.610;
            0.609,      0.680,      0.655,      0.390,      0.390,      0.390];

        % Determine altitude layer (refer to section 4.4.1 in Annex 10 for the
        % definition of "Layer") based on first altitude in vector:
        if encAlts(1) < 2300
            layer = 1;
        elseif encAlts(1) < 5000
            layer = 2;
        elseif encAlts(1) < 10000
            layer = 3;
        elseif encAlts(1) < 20000
            layer = 4;
        elseif encAlts(1) < 41000
            layer = 5;
        else
            layer = 6;
        end

        % If ownship, select lambda from layerData table. For intruders, Annex 10 
        % states: "? shall be selected randomly using the [layerData] 
        % probabilities".

        if acX == 1
            lambda = layerData(1,layer); %lambda1 for ownship
        else
            % Identify which lambda to use for target:
            lambdaProb = lambdaRand; % generate a random number
            if lambdaProb <= layerData(3, layer)
                lambda = layerData(1, layer); % Use lambda1 altitude error model
            else
                lambda = layerData(2, layer); % Use lambda2 altitude error model
            end
        end

        % Generate random variable from uniform distribution [-.5 .5] 
        u = randomValue-0.5; 

        % Sample Laplacian:
        altBias = -lambda * sign(u) * log(1 - 2 * abs(u));
        
      else
        
        altBias = 0;
        
      end

      %altsDegr = encAlts + altBias;
    
    end % function degradeAlt
    
    
    function dVrate  = degradeVrate(acVr, lambdaRandomValue, usePerfectAltimetry)
      % Vertical Rate Error Sampling
      % Model based on an analysis of Vertical Velocity Error Analysis performed
      % by David Elliott at MITRE during the TSAA program. The error behaved in a
      % Laplacian fashion with a 95% error bound at 336ft/min.

      % REVISIONS
      %  1/29/2013:   Initially completed
      %  12/14/2015:  Added documentation (Fabrice Kunzi)
      %  12/15/2015:  Changed estd to sigma, added clarification of how sigma is
      %               calculated.

      % Calculation
      % b is the scale parameter defining the spread of the distribution. For a
      % Laplacian Distribution, variance = sigma^2 = 2b^2. The 95_bound = 
      % 1.96 * % sigma. Together, b = 95_bound/(sqrt(2) * 1.96)
      % 
      % Two values that are of interest for modeling vertical velocity error:
      % 95_bound = 5.6ft/s    Equivalent to 95% bound of 336ft/min, as determined
      %                       empirically by analyis of installed Version 2 ADS-B 
      %                       avioncis.
      % 95_bound = 6.6ft/s    Equivalent to 95% bound of 400ft/min, as described
      %                       by FAA White Paper WP204-09 from SC-186, dated
      %                       December 2th, 2012.
      %
      % Note: 95_bound is in f/s, assuming that the input values for acVr are in
      % ft/second as well.
      
      if ~usePerfectAltimetry

        % Set desired bound:
        bound_95 = 5.6;

        % Calculate scaling parameter b:
        b = bound_95/(1.96 * sqrt(2));

        % Sample Laplacian:
        u = lambdaRandomValue - 0.5;
        eVrate = -b * sign(u) .* log(1- 2* abs(u));
        
      else
        
        eVrate = 0;
        
      end

      dVrate = acVr + eVrate;
    
    end % function degradeVRate
    
    
  end % methods
  
  
  
end % classdef