function gz_vals= compute_likelihood(model,z,X,X_freq,uav)

% compute likelihood vector g= [ log_g(z|x_1), ... , log_g(z|x_M) ] -
% this is for bearings and range case with additive Gaussian noise

M= size(X,2);
if M > size(X_freq,2)
   X_freq = repmat(X_freq,1,M);
end
Z = gen_observation_fn(model,X,X_freq,'noiseless',uav);
RSSI= Z(1,:);
e_sq=  (diag(1./diag(model.D))*(repmat(z(1,:),[1 M])- RSSI)).^2 ;
gz_vals= exp(-e_sq/2 - log(2*pi*prod(diag(model.D))));
