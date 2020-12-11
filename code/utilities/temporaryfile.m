classdef temporaryfile < handle
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% temporaryfile: Used in generating a temporary file name for simulating
% multiple encounters in parallal.
    properties
        file
    end
     
    methods
        function obj = temporaryfile(name,suffix)
            % Examples
            %   
            %   tmpfile = temporaryFile( [], '.mat' ); % Return a random filename ending in .mat
            %
            %   tmpfile = temporaryFile( 'existingFile' );
            if( nargin < 2 )
                suffix = [];
            end
            
            if ( nargin == 0 || isempty(name) )
                obj.file = [ tempname() suffix ];
                while( exist( obj.file, 'file' ) ~= 0 )
                    obj.file = [ tempname() suffix ];
                end
            else
                % Get absolute path so we can still delete it if current
                % directory changes
                f = java.io.File( pwd(), [ name suffix ] );
                obj.file = char( f.getCanonicalPath() );
            end
        end
        
        function delete(obj)
            if exist(obj.file, 'file')
                delete(obj.file)
            end
        end  
        
        function s = tostruct(obj)
            s = load_json(obj.file);
        end
    end
    
end
