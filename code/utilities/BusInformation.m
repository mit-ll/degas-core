classdef BusInformation
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% BusInformation: Information on what a Simulink bus looks like when 
% reduced to a vector as it is when sent through the output port of a top 
% level Simulink model
%
% This class is used to extract useful information from a Simulink.Bus
% object.  It is assumed that there are Simulink.Bus objects in the base
% MATLAB workspace describing any of the elements of this bus that are in
% turn buses themselves.  

    methods
        function this = BusInformation( busDescription )
            assert( isa( busDescription, 'Simulink.Bus' ) );
            
            this.widths_ = nan( numel(busDescription.Elements), 1 );      
            this.elementNames = cell( numel(busDescription.Elements), 1 );      
            
            for eIdx = 1 : numel(busDescription.Elements),
                if( startsWith( busDescription.Elements(eIdx).DataType, 'Bus: ' ) )
                    busname = busDescription.Elements(eIdx).DataType(6:end);
                    elementBusInfo = BusInformation( evalin( 'base', busname ) );
                    this.widths_(eIdx) = elementBusInfo.width;
                else
                    this.widths_(eIdx) = prod( busDescription.Elements(eIdx).Dimensions );
                end                
                this.elementNames{eIdx} = busDescription.Elements(eIdx).Name;
            end
            
            this.offsets_ = [ 1; cumsum( this.widths_(1:(end-1)) )+1 ];
            
            this.width = sum( this.widths_ );
            
        end
        function idx = getFlattenedLocation( this, elementName )
            %Returns where in a flattened vector the values of the indicated bus element are found
            eIdx = find(strcmp(this.elementNames,elementName));
            offset = this.offsets_(eIdx);
            ewidth = this.widths_(eIdx);
            
            idx = offset:(offset+ewidth-1);
        end        
    end       
    properties(SetAccess=private)
        width % the total number of signals in the flattened bus
    end
    
    properties(Access=private)
        widths_ % one entry for each top level bus element
        offsets_ % one entry for each top level bus element
    end
    properties(SetAccess=private)
        elementNames % cell array with one entry for each top level bus element
    end

end