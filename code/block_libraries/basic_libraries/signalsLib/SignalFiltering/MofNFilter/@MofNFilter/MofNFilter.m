classdef (Sealed = true) MofNFilter < Block
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% MofNFilter: Simulates a M of N filter
% 
% From the last N signal updates, at least M plots must have been 
% 'high' or 'low' to upgrade or downgrade a signal

    properties
        numSamples = 4;      % Total sample window
        numSamplesUp = 2;    % Samples needed to upgrade signal
        numSamplesDown = 2;  % Samples needed to downgrade signal
    end
    
    methods
        function obj = MofNFilter(tunableParameterPrefix,varargin) % Constructor
            if( nargin < 1 )
              tunableParameterPrefix = '';
            end

            p = inputParser;
            addRequired(p,'tunableParameterPrefix',@ischar);
            addOptional(p, 'numSamples', obj.numSamples, @isnumeric); 
            addOptional(p, 'numSamplesUp', obj.numSamplesUp, @isnumeric); 
            addOptional(p, 'numSamplesDown', obj.numSamplesDown, @isnumeric); 

            parse(p,tunableParameterPrefix,varargin{:});

            fieldsSet = intersect( fieldnames(p.Results), fieldnames(obj) );
            
            for i = 1:1:numel(fieldsSet)
                obj.(fieldsSet{i}) = p.Results.(fieldsSet{i});
            end
        end % constructor method 
%% Setters
% Setter functions set the value of the property of the object by calling
% the appropriate set function. The set functions have input handling built
% in so that the value the property is set to is valid. Like the
% aforementioned getter functions, the setter functions are not called
% explicitly, i.e. running "simObj.ac1MofNFilt.numSamples = 1" in the
% command line will call set.numSamples(obj, value)        
        
        function set.numSamples(obj, value)
            if(~isnumeric(value) || floor(value)~= value || value < 1)
                error('Invalid value for number of samples. numSamples must be an integer greater than zero.');
            else
                obj.checkSamples('all',value);
                obj.numSamples = value;
            end
        end
        function set.numSamplesUp(obj, value)
            if(~isnumeric(value) || floor(value)~= value  || value < 1)
                error('Invalid value for number of up samples. numSamplesUp must be an integer greater than zero.');
            else
                obj.checkSamples('up',value);
                obj.numSamplesUp = value;
            end
        end
        function set.numSamplesDown(obj, value)
           if(~isnumeric(value) || floor(value)~= value  || value < 1)
                 error('Invalid value for number of down samples. numSamplesDown must be an integer greater than zero.');
           else
               obj.checkSamples('down',value);
               obj.numSamplesDown = value;
            end
        end
        function checkSamples(obj,numSamps,value)
            %Only issue warning in case user is trying to change all of the
            %values
            if strcmp(numSamps,'all')
                if(obj.numSamplesUp > value)
                    warning('numSamps must be greater than or equal to numSamplesUp');
                end
                if (obj.numSamplesDown > value) 
                    warning('numSamps must be greater than or equal to numSamplesDown');
                end
            elseif strcmp(numSamps,'up') 
                if(value > obj.numSamples)
                    warning('numSamplesUp must be less than or equal to numSamples');
                end
            elseif strcmp(numSamps,'down')
                if(value > obj.numSamples)
                    warning('numSamplesDown must be less than or equal to numSamples');
                end
            end
        end
    end    
    
     methods(Access = 'public')
        function prepareProperties(obj)
            if obj.numSamples<obj.numSamplesUp
                error('numSamps must be greater than or equal to numSamplesUp');
            elseif obj.numSamples<obj.numSamplesDown
                error('numSamps must be greater than or equal to numSamplesDown');
            end
        end
     end
end