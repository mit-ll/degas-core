%Function that exists in 2012a, but not previous versions that we are using
%in Real Time Workshop

function assigninContext( varargin )
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11

assignin('base',varargin{1},varargin{2});
end