% sgain.m - transducer, available, and operating power gains of two-port
% 
% Usage: Gt = sgain(S,gG,gL)      (transducer power gain)
%        Ga = sgain(S,gG,'a')     (available gain - independent of load)
%        Gp = sgain(S,gL,'p')     (power gain - independent of generator)
%
%        Gu   = sgain(S,'u')      (maximum unilateral gain)
%        G1   = sgain(S,'ui')     (unilateral maximum input gain)
%        G2   = sgain(S,'uo')     (unilateral maximum output gain)
%        gufm = sgain(S,'ufm')    (unilateral figure of merit gain ratio)
%
%        Gmsg = sgain(S,'msg')    (maximum stable gain, use with K<1)
%
%        Gmag = sgain(S)          (maximum available gain, with simultaneous match)
%
% S    = 2x2 scattering matrix of two-port
% gG   = generator reflection coefficient (can be a row or column vector of values)
% gL   = load reflection coefficient (can be a vector of same length as gG)
%
% G = two-port gain in absolute units, use db(G) to convert to dB, (will be a vector if gG,gL are)
%
% notes: type 'a', calculates Ga by setting gL = conj(gout), 
%        type 'p', calculates Gp by setting gG = conj(gin),  
%
%        Gmax = sgain(S) corresponds to [gG,gL] = smatch(S)

% Sophocles J. Orfanidis - 1999-2008 - www.ece.rutgers.edu/~orfanidi/ewa

function G = sgain(S,g1,g2)

if nargin==0, help sgain; return; end

if nargin==1,
    K=sparam(S);
    if K<1, 
       fprintf('\nsimultaneous conjugate match does not exist\n\n'); 
       return; 
    end
    [g1,g2] = smatch(S);
    G = sgain(S,g1,g2);
end

if nargin==2,
    switch g1
      case 'u'
         G = abs(S(2,1))^2 / ((1 - abs(S(1,1))^2) * (1 - abs(S(2,2))^2));
      case 'ui'
         G = 1 / (1 - abs(S(1,1))^2);
      case 'uo' 
         G = 1 / (1 - abs(S(2,2))^2);
      case 'ufm'
         U = (S(1,2)*S(2,1)*conj(S(1,1)*S(2,2))) / ...
             ((1 - abs(S(1,1))^2) * (1 - abs(S(2,2))^2));
         G = 1 / abs(1-U)^2;
      case 'msg'
        if abs(S(1,2))~=0, 
          G = abs(S(2,1)/S(1,2)); 
        else
          G = inf;
        end
      otherwise
         G = sgain(S);
    end
end

if nargin==3,
    if g2=='a',
        gG = g1;
        gL = conj(gout(S,gG));
        G  = sgain(S,gG,gL);
    elseif g2=='p', 
        gL = g1;
        gG = conj(gin(S,gL));
        G  = sgain(S,gG,gL);
    else
        G = (1-abs(g1).^2) .* (1-abs(g2).^2) * abs(S(2,1))^2 ./ ...
            abs((1 - S(1,1)*g1).*(1 - S(2,2)*g2) - S(1,2)*S(2,1)*g1.*g2).^2;
    end
end



    

