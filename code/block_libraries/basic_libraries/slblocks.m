function blkStruct = slblocks
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%

% slblocks: Specify that the DEGAS Simulink libraries appear in the
% Simulink Library browser

    blkStruct.Browser(1).Library = 'controlLib';
    blkStruct.Browser(1).Name    = 'DEGASv1: Control Library';
    blkStruct.Browser(2).Library = 'dynamicsLib';
    blkStruct.Browser(2).Name    = 'DEGASv1: Dynamics Library';
    blkStruct.Browser(3).Library = 'logicAndResponseLib';
    blkStruct.Browser(3).Name    = 'DEGASv1: Logic and Pilot Response Library';
    blkStruct.Browser(4).Library = 'logicAndResponseLib';
    blkStruct.Browser(4).Name    = 'DEGASv1: Logic and Pilot Response Library';
    blkStruct.Browser(5).Library = 'metricsLib';
    blkStruct.Browser(5).Name    = 'DEGASv1: Metrics Library';
    blkStruct.Browser(6).Library = 'signalsLib';
    blkStruct.Browser(6).Name    = 'DEGASv1: Signals Library'; 
    blkStruct.Browser(7).Library = 'surveillanceLib';
    blkStruct.Browser(7).Name    = 'DEGASv1: Surveillance Library'; 