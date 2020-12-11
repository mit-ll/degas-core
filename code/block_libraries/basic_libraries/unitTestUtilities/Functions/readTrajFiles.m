function results = readTrajFiles(encId, encFolder,ownshipIdentifier,intruderIdentifier)
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%

%Read saved waypoint data
filename = [encFolder, '/' num2str(encId) '.txt'];
fid = fopen (filename, 'r');
csvdata = textscan(fid,'%s','delimiter',',');
fclose (fid);

%Gravity
g = 32.17405;

data = reshape(csvdata{:}, 8, [])';
% Search for OWNSHIP
ind_own = find (strcmp(data(:,1), ownshipIdentifier) == 1);

% Search for INTRUDER
ind_intr = find (strcmp(data(:,1), intruderIdentifier) == 1);

own_x_ft = str2double(data(ind_own,2));
own_y_ft = str2double(data(ind_own,3));
own_alt_ft = str2double(data(ind_own,4));
own_trk_rad = str2double(data(ind_own,5)); %deg to rad
own_gs_ftps = str2double(data(ind_own,6)); %kn to ftps
own_vs_ftps = str2double(data(ind_own,7))/60; %fpm to ftps
own_time_s = str2double(data(ind_own,8)); 

int_x_ft = str2double(data(ind_intr,2));
int_y_ft = str2double(data(ind_intr,3));
int_alt_ft = str2double(data(ind_intr,4));
int_trk_rad = str2double(data(ind_intr,5)); %deg to rad
int_gs_ftps = str2double(data(ind_intr,6)); %kn to ftps
int_vs_ftps = str2double(data(ind_intr,7))/60; %fpm to ftps
int_time_s = str2double(data(ind_intr,8)); 

%Ownship
results(1).time = own_time_s;
results(1).north_ft = own_y_ft; 
results(1).east_ft = own_x_ft;
results(1).up_ft = own_alt_ft;
results(1).speed_ftps = own_gs_ftps;
results(1).psi_rad = own_trk_rad;
results(1).theta_rad = asin(own_vs_ftps./own_gs_ftps); 
dpsi = [compute_delta_heading(results(1).psi_rad) ./ diff(own_time_s(1 : end)); 0]; %rad/sec
results(1).phi_rad = atan(results(1).speed_ftps.*dpsi/g);
results(1).Ndot_ftps = own_gs_ftps .* cos(own_trk_rad);
results(1).Edot_ftps = own_gs_ftps .* sin(own_trk_rad);
results(1).hdot_ftps = own_vs_ftps;

%Intruder
results(2).time = int_time_s;
results(2).north_ft = int_y_ft;
results(2).east_ft = int_x_ft;
results(2).up_ft = int_alt_ft;
results(2).speed_ftps = int_gs_ftps;
results(2).psi_rad = int_trk_rad;
results(2).theta_rad = asin(int_vs_ftps./int_gs_ftps); 
dpsi = [compute_delta_heading(results(2).psi_rad) ./ diff(int_time_s(1 : end)); 0]; %rad/sec
results(2).phi_rad = atan(results(2).speed_ftps.*dpsi/g);
results(2).Ndot_ftps = int_gs_ftps .* cos(int_trk_rad);
results(2).Edot_ftps = int_gs_ftps .* sin(int_trk_rad);
results(2).hdot_ftps = int_vs_ftps;
