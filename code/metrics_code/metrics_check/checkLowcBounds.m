function warnFlag = checkLowcBounds(hmds, vmds, varargin)
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% checkLowcBounds: Checks to see if the hmd and vmd distributions are 
% broader than the LoWC region
% hmds 1xN vector of horizontal missed distances
% vmds 1xN vector of vertical missed distances
% hmdTresh horizontal size of the LoWC region, default 4000 ft.
% altTresh vertical size of the LoWC region, default 450 ft.

    warnFlag = false;

    % Default wcv boundaries
    defHmdBound = 4000; % feet
    defAltTresh = 450; % feet

    lengthHmds = length(hmds);

    % Make a custom validation function based off of the length of the input
    eval(sprintf('validation_function = @(x) (length(x) == %i) && all(x >= 0) && (isvector(x));', lengthHmds))    
    
    % Input processing
    p = inputParser;
    addRequired(p,'hmds',validation_function);
    addRequired(p,'vmds',validation_function);
    validation_function = @(x) isscalar(x) && (all(x >= 0));
    addParameter(p,'hmdTresh',defHmdBound,validation_function);
    addParameter(p,'altTresh',defAltTresh,validation_function);
    parse(p,hmds,vmds,varargin{:});

    hmds = p.Results.hmds;
    vmds = p.Results.vmds;
    hmdTresh = p.Results.hmdTresh;
    altTresh = p.Results.altTresh;

    if all(hmds <= hmdTresh)
        warnFlag = true;
        warning('All hmds are within LoWC horizontal treshold.');
    end
    if all(vmds <= altTresh)
        warnFlag = true;
        warning('All vmds are within LoWC vertical treshold.');
    end
    if ~warnFlag
       disp([newline, 'HMD/VMD check complete. HMD/VMD distribution is larger than the LoWC region.', newline]) 
    end
end