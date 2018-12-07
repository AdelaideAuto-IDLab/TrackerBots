function mdl = non_linear_fit(tbl)
    modelfun = @(b,x) -2* 10*log10(x(:,1)) + b(1); beta0 = -1;% Fix n = 2
%     modelfun = @(b,x) -b(1)* 10*log10(x(:,1)) + b(2); beta0 = [-2 1];% For n changes
    
    ntarget = length(tbl);
    if ~iscell(tbl) && ntarget == 1, tblx{1} = tbl; tbl = tblx; end
    mdl = cell(ntarget,1);
    for i = 1:ntarget
        tbl{i} = orderfields(tbl{i});
        tblx{i} = struct2table(tbl{i});
        fprintf('Running for target %d/%d\t',i,ntarget);
        mdl{i} = fitnlm(tblx{i},modelfun,beta0); % Calculate model
        fprintf('Estimate Coefficients %2.2f\t',mdl{i}.Coefficients.Estimate);
        fprintf('Estimate RSME %2.2f\n',mdl{i}.RMSE);
    end
end