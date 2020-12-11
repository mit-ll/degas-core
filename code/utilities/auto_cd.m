classdef auto_cd < handle
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% An object that changes back to the original current directory when deleted
%
% Creating an auto_cd at the beginning of a function ensures that the user
% is returned to the current directory they were in when they called the 
% function, even if your function throws an error.  
%
% EXAMPLE
%
%   function result = myFunction( x, y, z )
%
%         % Make sure we get back to orig dir
%         autoOrigDir = auto_cd();
%
%         cd( tempdir() );
%         x = y + 1;
%         error( 'Something's wrong' );
%
%   end
%
    
    % Don't allow saving the orig_dir to a .mat file.
    % Otherwise loading an auto_ce from a .mat file can cause the MATLAB
    % working directory to change unexpectedly.  The preview pane in the
    % MATLAB GUI will trigger it!  Transient makes sure orig_dir=[] on
    % loaded auto_cd objects.  
    properties(SetAccess=private,Transient)
        orig_dir
    end
    
    methods
        function this = auto_cd()
            
            this.orig_dir = pwd();

        end
        
        function delete(this)

            % Note, auto_cd's loaded from .mat file will have empty
            % orig_dir.  If we don't do this check an error gets printed
            % when they are destroyed.  
            if( ~isempty( this.orig_dir ) ) 
                cd( this.orig_dir );
            end
            
        end  
    end
    
end

