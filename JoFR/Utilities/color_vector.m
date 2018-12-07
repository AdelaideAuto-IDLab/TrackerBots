function color_list = color_vector(ncolor)
    % Create a list of color vector appended from Color Order of GCA
    % Input: % Number of needed colors.
    % Output: List of ncolor in RGB matrix
    % Date: 28-01-2018
    % Rev: 1.0
    % Author: Hoa Van Nguyen
%     hfig = figure(1);
    hfig = figure();
    color_list = get(gca,'ColorOrder');
%     close hfig;
    if ncolor > size(color_list,1)
        n_color_rand = ncolor-size(color_list,1);
        color_list = [color_list;rand(n_color_rand,3)];
    else
        color_list = color_list(1:ncolor,:);
    end
    close(ancestor(hfig, 'figure'));
end