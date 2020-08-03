function xy_tng = pt_circ_tangent(ctr, r, XY, varargin)
    % PT_CIRC_TANGENT calculates and plots the tangent lines from 
    %     a point outside the circle to points on the 
    %     circumference.  It will throw an error if the point is 
    %     on or inside the circle.  
    % INPUT ARGUMENTS: 
    %     ctr: Two-element vector with the [x, y] coordinates of 
    %          circle center
    %     r: Scalar value of circle radius
    %     XY: Two-element vector of the [x,y] coordinates of the 
    %         point from which the tangent lines will be drawn
    %     varargin:
    %           'PlotResults': false on default, set true to plot
    % OUTPUTS: 
    %     xtng,ytng: Points on the circle to which the tangent 
    %         lines are plotted.

    %% --- Instantiate inputParser
    p = inputParser;
    % Setup parsing schema
    addParameter(p, 'PlotResults', false, @islogical);
    parse(p, varargin{:}); % Parse inputs

    a = linspace(0, 2*pi);                                              % Assign Angle Vector
    % r = 2;                                                              % Circle Radius (‘a’)
    % ctr = [0.0 0.0];                                                    % Circle Centre
    x = ctr(1) + r.*cos(a);                                             % Circle ‘x’ Vector
    y = ctr(2) + r.*sin(a);  
    % XY = [-5.5 3.5];                                                    % Point Outside Circle From Which Tangents Are Plotted
    c = hypot(XY(1)-ctr(1),XY(2)-ctr(2));
    if c <= r
        error('\n\tPOINT ON OR WITHIN CIRCLE RADIUS —> NO TANGENTS POSSIBLE!\n\n')
    end
    b = sqrt(c.^2 - r.^2);                                              % See Wikipedia Reference
    alfa = acos((r.^2 - b.^2 - c.^2)./(-2*b*c));                        % See Wikipedia Reference
    beta = acos((b.^2 - r.^2 - c.^2)./(-2*r*c));                        % See Wikipedia Reference
    pt_ctr_angl = atan2(-(XY(2)-ctr(2)),-(XY(1)-ctr(1)));               % Angle From ‘Point’ To Circle Centre
    alfac = [pt_ctr_angl + alfa; pt_ctr_angl - alfa];                   % Angles From ‘Point’ For Tangents
    xtng = XY(1) + [b.*cos(alfac(1)); b.*cos(alfac(2))];                % Tangent Point ‘x’ Coordinates
    ytng = XY(2) + [b.*sin(alfac(1)); b.*sin(alfac(2))];                % Tangent Point ‘y’ Coordinates
    if p.Results.PlotResults
        figure(1)
        plot(x, y)                                                          % Plot Circle
        hold on
        plot(XY(1), XY(2), 'bp')                                            % Plot ‘Point’
        plot([XY(1) xtng(1)], [XY(2) ytng(1)])                              % Plot Tangents
        plot([XY(1) xtng(2)], [XY(2) ytng(2)])                              % Plot Tangents
        hold off
        grid
        axis equal                                                          % Prevent Warping
    end
    xy_tng = [xtng ytng]';
end
