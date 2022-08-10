function [Xtr, Ytr, Xte, Yte] = gendata(ipd,labels, testind)
% The function requires input (ipd) to be a cell array with each cell as a matrix

trn = ipd(~testind);
ytrn = labels(~testind);

Xte = ipd(testind);
Yte = labels(testind);

Xtr = []; Ytr = []; 

for i = 1:numel(trn)

    Xtr = horzcat(Xtr,trn{i});
    Ytr = vertcat(Ytr, replab(ytrn(i),size(trn{i},2)));

end
end
