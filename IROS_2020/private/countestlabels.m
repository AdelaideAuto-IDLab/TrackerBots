function count= countestlabels(truth)
    labelstack= [];
    for k=1:truth.K
        if ~isempty(truth.X{k})
            labelstack= [labelstack truth.X_freq{k}'];
        end
    end
    [c,~,~]= unique(labelstack','rows');
    count=size(c,2);
end