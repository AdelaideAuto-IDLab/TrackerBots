function [Total_Gain,Horizontal_Polarization, Vertical_Polarization, Incident_Angle] = Reflection_Coefficient_Calculator(Freq,Ground_Distance, Height_Tx, Height_Rx,Relative_Dielectric_Constant,Conductivity,varargin )
    % This function to calculate the reflection coefficient in 2-ray model
    % with ground reflection based on formula at 
    % http://www.wirelesscommunication.nl/reference/chaptr03/pel/reflec.htm#spec
    % Input parameters: Freq,Ground_Distance, Height_Tx, Height_Rx,Relative_Dielectric_Constant,Conductivity
    % Output parameters: Total_Gain, Horizontal_Polarization, Vertical_Polarization, Incident_Angle
    % Written by Hoa V. Nguyen - Rev 0.
    % Last mod. Date: 29th Nov. 2017
    
    % Instantiate inputParser
    p = inputParser;
    % Setup parsing schema
    addParameter(p, 'UseGroundDistance', true, @islogical);
    % Parse inputs
    parse(p, varargin{:});
    
    Incident_Angle = atan((Height_Tx +Height_Rx)./Ground_Distance);
    x = 18e9 * Conductivity/Freq;
    Horizontal_Polarization = (sin(Incident_Angle) - sqrt((Relative_Dielectric_Constant - 1i*x) - cos(Incident_Angle).^2))./(sin(Incident_Angle) + sqrt((Relative_Dielectric_Constant - 1i*x) - cos(Incident_Angle).^2));
    Vertical_Polarization = ((Relative_Dielectric_Constant-1i*x).*sin(Incident_Angle)-sqrt(Relative_Dielectric_Constant - 1i*x - cos(Incident_Angle).^2))./((Relative_Dielectric_Constant-1i*x).*sin(Incident_Angle)+sqrt(Relative_Dielectric_Constant - 1i*x - cos(Incident_Angle).^2));
    % Phase
    l_reflect = sqrt(Ground_Distance.^2 + (Height_Tx+Height_Rx).^2) ;
    l = sqrt(Ground_Distance.^2 + (Height_Tx-Height_Rx).^2);
    Delta_Distance = l_reflect - l;
    Lambda = 3e8/Freq;
    Delta_Phi = 2*pi.*Delta_Distance/Lambda;
%     Total_Gain = 20*log10(real(1+ l./l_reflect.*Vertical_Polarization.*exp(-1i.*Delta_Phi))); % Use Vertical 
%     Total_Gain = real(1+ l./l_reflect.*Vertical_Polarization.*exp(-1i.*Delta_Phi)); % Use Vertical 
%     Total_Gain = abs(1+ l./l_reflect.*Horizontal_Polarization.*exp(-1i.*Delta_Phi));% .* abs(1+ l./l_reflect.*Vertical_Polarization.*exp(-1i.*Delta_Phi)); % Use Horizontal 
    Total_Gain = abs(Horizontal_Polarization.*exp(-1i*Delta_Phi)+1); % l/l_reflect cancelled out may be due to G_los /G_gr helps to cancel, unconfirm, guess only.
end