classdef (Sealed = true) Transponder < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% Transponder: Simulates a transponder with altimetry error    
     properties (GetAccess = 'public', SetAccess = 'public')        
        % Properties
        h_init_ft = 1000; %initial height
        equippage = TransponderEquippage.NONE;
        randNumAlterr = 0; %random number used to set altimetry error
        randNumLambda = 0; %random number used to set lambda
        altBias_ft = 0; %altimetry error
        alterr = BaroAlterr.POST; %whether to use 'during' or 'post' error (should be a BaroAlterr enum)
        model = BaroModel.ICAO; %whether to use the ICAO or European error model (should be a BaroModel enum)
    end % end properties
    
    methods(Access = 'public')
        function obj = Transponder (tunableParameterPrefix,varargin)
            p = inputParser;
            % Required Parameters
            addRequired(p,'tunableParameterPrefix',@ischar);
            addOptional(p,'h_init_ft',obj.h_init_ft,@isnumeric);
            addOptional(p,'equippage',obj.equippage);
            addOptional(p,'altBias_ft',obj.altBias_ft,@isnumeric);
            addOptional(p,'alterr',obj.alterr);
            addOptional(p,'model',obj.model);
            
            
            % Parse
            parse(p,tunableParameterPrefix,varargin{:}); 
            fieldsSet = intersect( fieldnames(p.Results), fieldnames(obj) );
            for i = 1:1:numel(fieldsSet)
                obj.(fieldsSet{i}) = p.Results.(fieldsSet{i});
            end

        end
    end
    
    %%
    methods
        function prepareProperties(obj)
            %Set the altimeter error                     
            obj.altBias_ft = obj.getAltimeterError;  
            
            %Do not set seed or error in prepareProperties
            %assert(isempty(obj.randNumAlterr) & isempty(obj.randNumLambda),'Do not set the random numbers yet') 
        end
    end
    
    %% Method used to compute altimeter error - need to fix the parameters in this method!!
    methods
        function alt_err = getAltimeterError(obj)
            if(obj.alterr == BaroAlterr.POST)
                % Altimetry error will be computed 'post' simulation
                alt_err = 0;
            else
                % Compute 'during' altimetry error
                % model = 1 indicates ICAO altimetry error model (default)
                % model = 0 indicates European altimetry error as used in JHU/APL SLAP
                % model only applies to equipped aircraft 
                % --> the same (ICAO) altimetry error is applied to unequipped aircraft 
                % h is the altitude of the own aircraft (ft)

                % Use the ICAO altimetry error model
                % Find altimeter error parameter, depending on altitude
                if (obj.h_init_ft <= 2300)
                    lambda = 35;
                    lambda2 = 60;
                    lamr = 0.391;
                elseif (obj.h_init_ft <= 5000)
                    lambda = 38;
                    lambda2 = 60;
                    lamr = 0.320;
                elseif (obj.h_init_ft <= 10000)
                    lambda = 43;
                    lambda2 = 69;
                    lamr = 0.345;
                elseif (obj.h_init_ft <= 20000)
                    lambda = 58;
                    lambda2 = 87;
                    lamr = 0.610;
                elseif (obj.h_init_ft <= 41000)
                    lambda = 72;
                    lambda2 = 101;
                    lamr = 0.610;
                else
                    lambda = 94;
                    lambda2 = 101;
                    lamr = 0.610;
                end

                % For unequipped aircraft under both models: 
                % use lambda unless aircraft does not have good altimeter, in which case
                % there is a probability lamr of using lambda, otherwise lambda2
                % Possible values for equippage:
                % NONE    = 0; MODE_C  = 1; MODE_S  = 2;
                % MITCAS = 5;
                if (obj.equippage == TransponderEquippage.NONE || obj.equippage == TransponderEquippage.MODE_C); 
                    %Random number for determining which lambda to use
                    r = obj.randNumLambda; 
                    if (r > lamr)
                        lambda = lambda2;
                    end
                elseif (obj.model == 0)
                    %The aircraft is equipped and wish to use the Eurocontrol altimetry error model used in JHU/APL SLAP
                    lambda = 35;
                end

                % uniform random number for determining altimeter error
                f = obj.randNumAlterr; 

                % altimeter error cumulative distribution derived from ICAO standard
                if (f <= 0.5)
                    alt_err = lambda*log(2*f);
                else
                    alt_err = -lambda*log(2*(1-f));
                end
            end
        end     
             
    end
    
    %% Setters
    methods
        function obj = set.h_init_ft(obj, value)
            assert(isnumeric(value),'Invalid h_init_ft, must be numeric');
            obj.h_init_ft = value;
        end
        
        function obj = set.equippage(obj,value)
            assert( isa( value, 'TransponderEquippage' ) );
            obj.equippage = value;
        end
        
        function obj = set.randNumAlterr(obj, value)
            assert(value >= 0 & value <= 1,'Invalid randNumAlterr, must be between 0 and 1');
            obj.randNumAlterr = value;
        end
        
        function obj = set.randNumLambda(obj, value)
            assert(value >= 0 & value <= 1,'Invalid randNumLambda, must be between 0 and 1');
            obj.randNumLambda = value;
        end
        
        function obj = set.altBias_ft(obj, value)
            assert(isnumeric(value),'Invalid altBias_ft, must be numeric');
            obj.altBias_ft = value;
        end
        
        function obj = set.alterr(obj, value)
            assert( isa( value, 'BaroAlterr' ) );
            obj.alterr = value;
        end
        
        function obj = set.model(obj, value)
            assert( isa( value, 'BaroModel' ) );
            obj.model = value;
        end
        
    end % End methods
end