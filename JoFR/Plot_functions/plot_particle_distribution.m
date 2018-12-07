function hfigs = plot_particle_distribution(TargetID, pf,k,est,truth,plot_title) 
% Input: particles info pf, time index k
% Output: plot
    
    ptk = pf{TargetID}.particles(:,:,k);
    pwk = pf{TargetID}.w(:,k);
%     pwk = ones(1,pf{TargetID}.Ns)./pf{TargetID}.Ns;
    hfig = scatter(ptk(1,:),ptk(2,:),[],pwk,'filled');
    title(plot_title);
    grid on; hold on;
    set(gca, 'FontSize', 20);
%     axis([0,pf{TargetID}.R_max,0,pf{TargetID}.R_max]);
    xlabel('x (m)');
    ylabel('y (m)');
%                 set(ax(1),'YTick',[0:10:100]);
%     colorbar;
%     drawnow; 
    i = TargetID;
    htruth = plot(truth.X{i}(1,k),truth.X{i}(2,k), 'LineWidth',2, 'Color' , 'red' , 'Marker' , 's','markersize',10,'MarkerFaceColor', 'white');
    hest = plot(est.X{i}(1,k),est.X{i}(2,k),'LineWidth',2,'Color' , 'blue' , 'Marker' , '*','markersize',10,'MarkerFaceColor', 'white');
    hfigs = [hfig,htruth,hest];
    legend(hfigs,{'Particles','Truth', 'Estimated'},'Location','best');
    hold off;
end