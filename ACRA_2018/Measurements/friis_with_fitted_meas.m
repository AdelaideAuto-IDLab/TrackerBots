function Pr = friis_with_fitted_meas(x,uav,yagi_2elements_gain,varargin)
% Instantiate inputParser
p = inputParser;
% Setup parsing schema
addRequired(p,'x',@ismatrix); %ischar
addRequired(p,'uav',@ismatrix); %ischar
addRequired(p,'yagi_2elements_gain',@isstruct); %ischar
addParameter(p, 'Use2Ray', false, @islogical);
addParameter(p, 'Use3D', false, @islogical);
addParameter(p, 'UseDEM', false, @islogical);
addParameter(p,'DEM_FileName', 'DEM_SA_Table');
addParameter(p, 'ChangeHeight', false, @islogical);
addParameter(p, 'current_url', 'http://football.local:8000', @ischar);
addParameter(p,'mdp_cycle', 7);
parse(p, x,uav,yagi_2elements_gain, varargin{:});% Parse inputs
% disp(p.Results); % For fun, show the results

if size(x,2) > size(uav,2)
   uav = repmat(uav,1,size(x,2));
elseif size(x,2) < size(uav,2)
   x = repmat(x,1,size(uav,2));
end

v1 = x(1:2,:) - uav(1:2,:);
v2 = [sin(uav(4,:)); cos(uav(4,:))]; %% In NE coordinate    
x1 = v1(1,:); y1 = v1(2,:);
x2 = v2(1,:); y2 = v2(2,:);
phi=mod( atan2(x1.*y2-y1.*x2,dot(v1,v2)),2*pi) ;  

gh = yagi_2elements_gain.gh';
ge = yagi_2elements_gain.ge';
N = yagi_2elements_gain.N;
pos_relative = (x-uav(1:3,:));

[~,theta,r] = cart2sph(pos_relative(1,:),pos_relative(2,:),pos_relative(3,:)); % convert from cartesian to spherical coordinate
theta = mod(theta,2*pi);

if ~p.Results.Use2Ray
    Pr = -35.4 -20*log10(r) + 10*log10(gh(floor(theta/(2*pi)*N)+1)) + 10*log10(ge(floor(phi/(2*pi)*N)+1)); % Model is fitted based on previous measurement data
else
    Freq = 150e6;
    Ground_Distance =  sqrt(sum(v1.^2,1));
    Height_Tx = x(3,:);
    Height_Rx = uav(3,:);
    Relative_Dielectric_Constant = 15; % 7
    Conductivity = 5e-3; % 10e-3
    Total_Gain = Reflection_Coefficient_Calculator(Freq,Ground_Distance, Height_Tx, Height_Rx,Relative_Dielectric_Constant,Conductivity );
    Pr = -39.67	-20*log10(r./Total_Gain) + 10*log10(gh(floor(theta/(2*pi)*N)+1)) + 10*log10(ge(floor(phi/(2*pi)*N)+1)) ; % original: -39.67
end

end