function handler = Plot_Target_Estimated_Position (model, truth, est, meas,colorarray,varargin)
    % ---Input Parser
    p = inputParser;
    % Setup parsing schema
    addParameter(p,'K', truth.K, @isnumeric);
    addParameter(p,'Transparency', 1, @isnumeric);
    parse(p, varargin{:});
    K = p.Results.K;
    Transparency = p.Results.Transparency;
%     K = truth.K;
    
    font_size = 20;
    [X_track,k_birth,k_death]= extract_tracks(truth.X,truth.track_list,truth.total_tracks);
    if nargin <5
        labelcount= countestlabels(truth)+1;
        colorarray= makecolorarray(labelcount);
    end
    ntarget = truth.total_tracks;
    
    R_max = model.limit(2,2);

    figure(ntarget+1); handler= gcf; 
    set(handler, 'Position', [100 500 600 600]);
    axis square;
    scatter(0,0,100,'Marker','p','MarkerFaceColor','red','LineWidth',2,'MarkerEdgeColor', 'red');
    % subplot(2,2,1);
    hold on; grid on; 
    for i=1:ntarget
       k_b_temp = k_birth(i); k_b_temp = k_b_temp(k_b_temp<=K);  % update birth time
       k_d_temp = k_death(i); k_d_temp = min(k_d_temp,K);   % update death time
       life_temp = k_b_temp : k_d_temp;
       pos_temp = X_track(:,:,i);
       if K > k_d_temp, Transparency_temp = Transparency; else, Transparency_temp = 1; end
       if ~isempty(k_b_temp)
           color_temp = colorarray.rgb(assigncolor(truth.X_freq{k_birth(i)}(i)),:) ;
           htruth{i} = plot(pos_temp(1,life_temp),pos_temp(2,life_temp),'LineWidth',2, 'LineStyle','-','Color' , color_temp);
           htruth{i}.Color(4) = Transparency_temp;
       end
    end
    for i=1:ntarget
       k_b_temp = k_birth(i); k_b_temp = k_b_temp(k_b_temp<=K);  % update birth time
       k_d_temp = k_death(i); k_d_temp = min(k_d_temp,K);   % update death time
       pos_temp = X_track(:,:,i);
       if K > k_d_temp, Transparency_temp = Transparency; else, Transparency_temp = 1; end
       color_temp = colorarray.rgb(assigncolor(truth.X_freq{k_birth(i)}(i)),:) ;
       if ~isempty(k_b_temp)
           text(pos_temp(1,k_d_temp) +10,pos_temp(2,k_d_temp) + 10, num2str(i),'FontName','Times New Roman','FontSize',font_size); 
%            plot_temp = scatter(pos_temp(1,k_b_temp),pos_temp(2,k_b_temp),50, 'LineWidth',1,...
%                'Marker' , 'o', 'MarkerFaceColor',color_temp, 'MarkerEdgeColor', 'black');
%            plot_temp.MarkerEdgeAlpha =  Transparency_temp; plot_temp.MarkerFaceAlpha =  Transparency_temp;
%            plot_temp = scatter(pos_temp(1,k_d_temp),pos_temp(2,k_d_temp),50, 'LineWidth',1,...
%                'Marker' , 's', 'MarkerFaceColor',color_temp, 'MarkerEdgeColor', 'black');
           
           plot_temp.MarkerEdgeAlpha =  Transparency_temp; plot_temp.MarkerFaceAlpha =  Transparency_temp;
       end
    end
    if nargin == 2
        plot(model.rect.R(:,1),model.rect.R(:,2),'m-','LineWidth',2); 
        
        xlabel('x-coordinate (m)', 'FontSize', font_size);
        ylabel('y-coordinate (m)', 'FontSize', font_size);
        set(gca, 'FontSize', font_size, 'FontName', 'Times New Roman');
        grid off;
        axis(reshape(model.limit()',1,4)); axis equal;
        set(gcf,'color','w');
        return; 
    end
    color_temp = colorarray.rgb(end,:); % Use last as UAV color index
    huav = plot(meas.uav(1,1:K), meas.uav(2,1:K),'-', 'LineWidth',1, 'Color' , color_temp);
    viscircles(meas.uav(1:2,K)',model.Void_Radius,'Color',color_temp,'LineStyle',':','LineWidth',2);
%     plot(meas.uav(1,1),meas.uav(2,1),'LineWidth',1, 'Color' , color_temp,  ...
%             'Marker' , 'o','markersize',8 , 'MarkerFaceColor',color_temp, 'MarkerEdgeColor', 'black' );
%     plot(meas.uav(1,K),meas.uav(2,K), 'LineWidth',1, 'Color' , color_temp,...
%            'Marker' , 's','markersize', 8 , 'MarkerFaceColor',color_temp, 'MarkerEdgeColor', 'black');
    plot(model.rect.R(:,1),model.rect.R(:,2),'m-'); 
    foundX_Best = cell2mat(est.foundX_Best');
   
   for i = 1 : size(foundX_Best,2)
       selFreq = foundX_Best(4,i);
       pos_temp = foundX_Best(1:2,i);
       color_temp = colorarray.rgb(assigncolor(selFreq),:);

%        labelpoints(pos_temp(1) +1,pos_temp(2) + 1, num2str(i),'FontSize',font_size); 
       yhline2= scatter(pos_temp(1),pos_temp(2),80, 'LineWidth',1,...
           'Marker' , '*', 'MarkerFaceColor',color_temp, 'MarkerEdgeColor', color_temp);
       yhline2.MarkerEdgeAlpha =  Transparency_temp; yhline2.MarkerFaceAlpha =  Transparency_temp;
       
   end
       
%    R1 = est.X(1:K); R2 = est.X_freq(1:K);
%    
%    temp1 = R1(~cellfun('isempty',R1));
%    temp2 = R2(~cellfun('isempty',R2));
%    temp = cellfun(@(x,y) [x;y'],temp1,temp2,'UniformOutput',false);
%    temp = [temp{:}];
%    temp = sortrows(temp',8)';
%    temp = temp([1 3 8],:);
%    temp_freq = unique(temp(3,:));
%    
%    for i = 1: length(temp_freq)
%       selFreq =  temp_freq(i);
%       if sum(selFreq ==  truth.X_freq{K}) == 0, Transparency_temp = Transparency; else, Transparency_temp = 1; end
%       P = temp(:,selFreq == temp(3,:));
%       selColor = colorarray.rgb(assigncolor(selFreq),:);
%       yhline2= scatter(P(1,:),P(2,:),'LineWidth',0.5,'Marker','.','MarkerEdgeColor',selColor,'MarkerFaceColor',selColor);
%       yhline2.MarkerEdgeAlpha = Transparency_temp; yhline2.MarkerFaceAlpha = Transparency_temp;
% %       yhline2= line(P(1,:),P(2,:),'LineWidth',1,'LineStyle','-','Marker','.','Markersize',6,'Color',colorarray.rgb(assigncolor(selFreq),:));
%    end
    
    hlegend = [];
    count = 0;
    
    hlegend = [hlegend,htruth{end}, yhline2];
    for j=1:2
        count = count + 1;
        if j ==1
            hLegendName{count} = ['Real position of Target'];
        else
            hLegendName{count} = ['Estimated position of Target'];
        end 
    end
    hLegendName{count+1} = 'UAV Trajectory';
    % hLegendName{count+2} = 'Real UAV Trajectory';
    hlegend = [hlegend, huav];%,huav_real];
    legend(hlegend,hLegendName,'Location','best');
    hold off;
    grid off; 
    
%     title('Position estimation with Particle filter & POMDP.', 'FontSize', 20);
    xlabel('x-coordinate (m)', 'FontSize', font_size);
    ylabel('y-coordinate (m)', 'FontSize', font_size);
%     set(gca, 'FontSize', font_size);
    set(gca, 'FontSize', font_size, 'FontName', 'Times New Roman');
%     for i=1:ntarget
%        labelpoints(est.X{i}(1,est.foundIndex{i}) +1,est.X{i}(2,est.foundIndex{i})+1, num2str(i)); 
%     %    text(est.X{i}(1,est.foundIndex{i}) +1,est.X{i}(2,est.foundIndex{i})+1, num2str(i));
%     end
    % axis([0,350,0,350]);
%     axis([0,R_max*1.1,0,R_max*1.1]);
    axis(reshape(model.limit()',1,4));axis equal
    
    function idx= assigncolor(label)
        str= sprintf('%i*',label);
        tmp= strcmp(str,colorarray.lab);
        if any(tmp)
            idx= find(tmp);
        else
            colorarray.cnt= colorarray.cnt + 1;
            colorarray.lab{colorarray.cnt}= str;
            idx= colorarray.cnt;
        end
    end
end


