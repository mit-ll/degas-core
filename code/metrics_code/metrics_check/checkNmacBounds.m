function warnFlag = checkNmacBounds(hmds, vmds, varargin)
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%
% checkNmacBounds: checks to see if the hmd and vmd distribution are broader
% than the NMAC region
% hmds 1xN vector of horizontal missed distances
% vmds 1xN vector of vertical missed distances
% hmdBound horizontal size of the NMAC region, default 500 ft.
% vmdBound vertical size of the NMAC region, default 100 ft.

    warnFlag = false;

    % Default NMAC boundaries
    defHmdBound = 500; % feet
    defVmdBound = 100; % feet

    lengthHmds = length(hmds);

    % Make a custom validation function based off of the length of the input
    eval(sprintf('validation_function = @(x) (length(x) == %i) && all(x >= 0) && (isvector(x));', lengthHmds))

    % Input processing
    p = inputParser;
    addRequired(p,'hmds',validation_function);
    addRequired(p,'vmds',validation_function);
    validation_function = @(x) isscalar(x) && (all(x >= 0));
    addParameter(p,'hmdBound',defHmdBound,validation_function);
    addParameter(p,'vmdBound',defVmdBound,validation_function);
    parse(p,hmds,vmds,varargin{:});

    hmds = p.Results.hmds;
    vmds = p.Results.vmds;
    hmdBound = p.Results.hmdBound;
    vmdBound = p.Results.vmdBound;

    % Checking HMD and VMD against NMAC boundaries
    if all(hmds <= hmdBound)
        warnFlag = true;
        warning([newline, 'All hmds are within NMAC horizontal bounds', newline]);
    end
    if all(vmds <= vmdBound)
        warnFlag = true;
        warning([newline, 'All vmds are within NMAC vertical bounds.', newline]);
    end
    if ~warnFlag
       disp([newline, 'HMD/VMD check complete. HMD/VMD distribution is larger than the NMAC region.', newline]) 
    end
end