function daidalusBandViz(simObject)
% Copyright 2008 - 2020, MIT Lincoln Laboratory
% SPDX-License-Identifier: X11
%

% daidalusBandViz: Plot the DAIDALUS bands along with nominal and commanded
% trajectories
%
% DAIDALUS outputs a N x 283 element array where N is the length of the 
% simulation in seconds. The first 271 elements show the safety of 
% maneuvering to headings [-135:135] relative to the ownships current 
% heading. The band alert level at each heading can range from [0,1,3,4], 
% 0 being no alert, 1 being regain well clear, 3 being corrective alert,
% and 4 being warning alert.

    % Turn off autocomplete for legends -- an annoying feature of Matlab 2018
    set(0, 'DefaultLegendAutoUpdate', 'off');

    sr1 = simObject.results(1);
    sr2 = simObject.results(2);
    srn = simObject.results_nominal(1);
    sso = simObject.simOut;
    so  = simObject.outcome;
    
    try
        tot_guidance = simObject.readFromWorkspace('daaGuidance');
    catch
        error(['No ''To Workspace'' block labeled ''daaGuidance'' exists in the simulation. ', ...
               'Please add that block, route the ''Guidance'' output from DAIDALUS to the block ',...
               'and rerun the simulation.']);
    end
    % Horizontal Guidance
    
    horz_guidance = tot_guidance(:,1:271);

    [rows,~] = size(horz_guidance);

    ownHeadings = sr1.psi_rad;

    ownHeadings = ownHeadings(1:10:end)*DEGAS.rad2deg;

    ownHeadings = round(ownHeadings);
    
    nomHeadings = srn.psi_rad; 
    
    nomHeadings = nomHeadings(1:10:end)*DEGAS.rad2deg;
    
    nomHeadings = round(nomHeadings);
    
    bands = -135:135;
    
    figure;
    subplot(1,2,1)
    hold on;
    
    xData = 0:(rows-1);    
    
    c1 = plot(ownHeadings,xData,'k');    
    
    c2 = plot(nomHeadings,xData,'--k');

    legend('Actual Heading')
    
    legend('Actual Heading','Nominal Heading','Location','southeast')    
    
    for i = 1:rows

        idx = horz_guidance(i,:) == 4;
        xData = ones(1,length(idx))*(i-1);
        plot(bands(idx)+ownHeadings(i),xData(idx),'sr','MarkerFaceColor','r');

        idx = horz_guidance(i,:) == 1;
        xData = ones(1,length(idx))*(i-1);
        plot(bands(idx)+ownHeadings(i),xData(idx),'sg','MarkerFaceColor','g');
        
        idx = horz_guidance(i,:) == 3;
        xData = ones(1,length(idx))*(i-1);
        plot(bands(idx)+ownHeadings(i),xData(idx),'sy','MarkerFaceColor','y');        
        
    end   
    
    uistack(c1,'top')
    uistack(c2,'top')
    
    xData = 0:(rows-1);
    
    wcv_idx = round(so.tLossofWellClear)+1;
    
    if ~isnan(wcv_idx)
    
        plot(ownHeadings(wcv_idx),xData(wcv_idx),'kx')    
        text(ownHeadings(wcv_idx),xData(wcv_idx),'  LoWC','FontSize',8)
    
    end
    
    plot(ownHeadings(round(so.tca)),xData(round(so.tca)),'kx')
    text(ownHeadings(round(so.tca)),xData(round(so.tca)),'  tca','FontSize',8)
    
    grid on;
    grid minor;
    
    pbaspect([1 1 1])
    xlabel('Heading (deg)')
    ylabel('Time (s)')
    title('DAIDALUS Horizontal Guidance')
    
    % Vertical guidance
    
    vert_guidance = tot_guidance(:,272:end);
    
    u1 = sr1.up_ft(1:10:end);
    
    u2 = sr2.up_ft(1:10:end);
    
    time = sso.get('tout');
    
    time = time(1:10:end);
    
    nom_alt = srn.up_ft;
    
    nom_alt = nom_alt(1:10:end);
    
    subplot(1,2,2)
    hold on;
    c1 = plot(time,u1,'k');          
    c2 = plot(time,u2,'b.');
    c3 = plot(time,nom_alt,'k:');
    legend('Ownship Altitude','Intruder Altitude','Location','SouthWest');
    
    for i = 1:6
        
        x = vert_guidance(:,((i-1)*2)+1)';
        y = vert_guidance(:,(i*2))';
        
        idx = y == 1;
        x_plot = time(idx);
        y_plot = x(idx);
        plot(x_plot,y_plot,'sg','MarkerFaceColor','g')
        
        idx = y == 3;
        x_plot = time(idx);
        y_plot = x(idx);
        plot(x_plot,y_plot,'sy','MarkerFaceColor','y')
        
        idx = y == 4;
        x_plot = time(idx);
        y_plot = x(idx);
        plot(x_plot,y_plot,'sr','MarkerFaceColor','r')
        
    end
    
    yl = ylim;
    
    if ~isnan(wcv_idx)
    
        plot([wcv_idx-1 wcv_idx-1],[yl(1) yl(2)],'k:')
        plot(time(wcv_idx),u1(wcv_idx),'kx')
        text(time(wcv_idx),u1(wcv_idx) - 20,'  LoWC','FontSize',8)
        
    end
    
    plot([time(round(so.tca)) time(round(so.tca))],[yl(1) yl(2)],'k:')
    plot(time(round(so.tca)),u1(round(so.tca)),'kx')
    text(time(round(so.tca)),u1(round(so.tca)) - 20,'  tca','FontSize',8)
    
    uistack(c1,'top')
    uistack(c2,'top')    
    uistack(c3,'top')    
    
    pbaspect([1 1 1]);
    xlabel('Time (s)');
    ylabel('Altitude (ft.)');
    title('DAIDALUS Vertical Guidance');
    grid on;
    grid minor;
    
end