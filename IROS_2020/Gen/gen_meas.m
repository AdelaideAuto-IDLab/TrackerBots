function meas = gen_meas(model,truth,uav)

    %variables
    meas.Z = cell(truth.K,1);
    for k=1:truth.K
        if truth.N(k) > 0   
            try
                meas.Z{k} = gen_observation_fn(model,truth.X{k},truth.X_freq{k},'noise',uav);                          %single target observations if detected     
                meas.Z{k} = sortrows(meas.Z{k}',2)'; % sort by frequency index
            catch
                fprintf('Error when generating measurements at time %d/%d \n',k,truth.K);
            end     
        end   
    end
    meas = meas.Z{1};
    
end