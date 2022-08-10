function [Xtr, Ytr, Xte, Yte] = gendata(ipd,labels, testind)
% The function requires input (ipd) to be a cell array with each cell as a matrix

trn = ipd(~testind);
ytrn = labels(~testind);

Xte = ipd(testind);
Yte = labels(testind);

Xtr = []; Ytr = []; 

h = waitbar(0,'Please wait...');

for i = 1:numel(trn)

    Xtr = horzcat(Xtr,trn{i});
    Ytr = vertcat(Ytr, replab(ytrn(i),size(trn{i},2)));
    
    waitbar(i/numel(trn), h, sprintf('Generating Train/Test data: %d %%', floor(i/numel(trn)*100)));
end

close(h)

end
