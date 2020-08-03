function Z = gen_observation_fn(model,X,X_freq,W,uav)

yagi_2elements_gain = model.yagi_2elements_gain;
%r/t observation equation

if ~isnumeric(W)
    if strcmp(W,'noise')
        W= model.D*randn(size(model.D,2),size(X,2));
    elseif strcmp(W,'noiseless')
        W= zeros(size(model.D,1),size(X,2));
    end
end

if isempty(X)
    Z= [];
else %modify below here for user specified measurement model
    if size(X,2) > size(uav,2)
       uav = repmat(uav,1,size(X,2));
    elseif size(X,2) < size(uav,2)
       X = repmat(X,1,size(uav,2));
       X_freq = repmat(X_freq,1,size(uav,2));
    end
        
    v1 = X(1:2,:) - uav(1:2,:);
    v2 = [sin(uav(4,:)); cos(uav(4,:))]; %% In NE coordinate    
    x1 = v1(1,:); y1 = v1(2,:);
    x2 = v2(1,:); y2 = v2(2,:);
    phi= mod( atan2(x1.*y2-y1.*x2,dot(v1,v2)),2*pi) ; 
    gh = yagi_2elements_gain.gh';
    ge = yagi_2elements_gain.ge';
    N = yagi_2elements_gain.N;
    pos_relative = (X-uav(1:3,:));
    [~,theta,r] = cart2sph(pos_relative(1,:),pos_relative(2,:),pos_relative(3,:)); % convert from cartesian to spherical coordinate
    theta = mod(theta,2*pi);
    
    Freq = 150e6;
    Ground_Distance =  sqrt(sum(v1.^2,1));
    Height_Tx = ones(1,size(X,2));
    Height_Rx = uav(3,:);
    Relative_Dielectric_Constant = 15;
    Conductivity = 5e-3; 
    Total_Gain = Reflection_Coefficient_Calculator(Freq,Ground_Distance, Height_Tx, Height_Rx,Relative_Dielectric_Constant,Conductivity );
    Pr = -39.67	-20*log10(r./Total_Gain) + 10*log10(gh(floor(theta/(2*pi)*N)+1)) + 10*log10(ge(floor(phi/(2*pi)*N)+1)) ; % transmitted power ~ 0.1 mW at d = 1
    Z = Pr + W;
    Z = [Z;X_freq];
end