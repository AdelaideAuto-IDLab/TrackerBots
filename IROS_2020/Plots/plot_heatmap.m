function hmap = plot_heatmap(MC_Results, area, resolution)
% Path: cell array contain path data
% area: [x, y] length
% resolution: 

    n_path = length(MC_Results.meas);
    x = area(1);
    y = area(2);
    
    hmap = zeros(round(x/resolution), round(y/resolution));
    
    for n = 1:n_path
       tmp_path = [round(MC_Results.meas{n}.uav(1,:)/resolution); round(MC_Results.meas{n}.uav(2,:)/resolution)]; 
       % inte
       
       for l = 1:length(MC_Results.meas{n}.uav)
           if tmp_path(1,l)<x/resolution && tmp_path(2,l) < y/resolution
            hmap(tmp_path(1,l)+1, tmp_path(2,l)+1) = hmap(tmp_path(1,l)+1, tmp_path(2,l)+1) + 1;
           end
       end
    end
    
    hmap(1,1) = 1;
    
    % convert to log scale
    hmap = hmap + 1;
    hmap = 10*log(hmap);
    
    hmap = hmap/max(hmap,[],'All');
    
    % plot 
    figure();
    imagesc(hmap', 'xData',[0, area(1)], 'yData', [0, area(2)]);
    xlabel('x (m)');
    ylabel('y (m)');
    set(gca,'YDir','normal')

end