classdef SLoWC < MetricBlock
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
%SLoWC:  Wrapper class for DEGAS SLoWC block.  Adds the
%worst-case value of the Severity of Loss of Well Clear metric (the maximum
%value) to the simulation object's 'outcome' structure.
  
  properties
    
    slowc
    
  end % properties
  
  
  methods
    
    function this = SLoWC( simObj )
      this = this@MetricBlock( simObj );
    end
    
    function metricStruct = addMetrics( this, metricStruct )
      metricStruct.SLoWC = this.slowc;
    end
    
    function onSimulationComplete( this, simObj )
      this.slowc = simObj.readFromWorkspace( 'slowc' );
    end
    
    
  end % methods
  
  
  
end % classdef