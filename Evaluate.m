function metrics = Evaluate(X,Xhat) 


confmat = confusionmat(X,Xhat);

% Array initialization
N = size(confmat,1);

Precision = zeros(1,N);
Recall = zeros(1,N);
Specificity = zeros(1,N);
Accuracy = zeros(1,N);
F1score = zeros(1,N);


TP = confmat(1, 1);
FP = confmat(2, 1);
FN = confmat(1, 2);
TN = confmat(2,2);

Precision = TP / (TP+FP); % positive predictive value (PPV)
Recall    = TP / (TP+FN); % true positive rate (TPR), sensitivity
F1score  = (2 * Precision * Recall) / (Precision + Recall);
Accuracy = (TP+TN)/(TP+TN+FP+FN); % Accuracy
mcc = (TP*TN-FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN)); % Mathew's correlation coefficient

% Output
metrics.Precision = Precision;
metrics.Recall = Recall;
metrics.Accuracy = Accuracy;
metrics.F1score = F1score;
metrics.mcc = mcc;
