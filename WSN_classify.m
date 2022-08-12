clc;
rng(3,'twister')

%% ------------------- Reading and preparing data -------------------
fs = 16000;
wavdir = './SVDdata';
T = readtable([wavdir '/metadata.xlsx']);
T1 = T{:,1};
L1 = table2array(T(:,2));

speechdata = {}; lab = []; Nfps = [];

for j = 1:size(T1,1)
         
    fprintf('Collecting speech signals of speaker ---> %d\n', T1(j)); 
    file_list = dir(fullfile(wavdir, '**', [num2str(T1(j)) '-' '*.wav']));

    for si = 1:length(file_list)

         wav_name = ([file_list(si).folder '/' file_list(si).name]);
         [data,Fs] = audioread(wav_name); 
         data = resample(data,fs,Fs);
         speechdata{end+1} = data';
    end    
    
    lab = [lab;L1(j)];
    Nfps = [Nfps;length(file_list)];

end  

%% -----------------  Feature Extraction ---------------------

Features = {};
h = waitbar(0,'Please wait...');
    
for i = 1:numel(speechdata)
     temp = speechdata{i};
     sn = waveletScattering('SignalLength',size(temp,2), 'InvarianceScale',0.25, ...
                            'SamplingFrequency',fs,'QualityFactors',[8 1]);
                    
     coeffs = featureMatrix(sn, temp,'Transform', 'log');
     Features{end+1} = coeffs(2:end,:);
    
     waitbar(i/numel(speechdata), h, sprintf('Extracting features: %d %%', floor(i/numel(speechdata)*100)));
       
end
close(h)

%% ---------------- Training and Evaluation -------------
% Perform 5-fold cross-validation with 80% speakers data for training and
% 20% speakers data for testing in each fold.

kfold = 5;
labels = replab(lab,Nfps);
stats_mlp = [];

for i = 1:kfold
fprintf('Fold --> %d\n',i);

ind = crossvalind('Kfold', lab, kfold);
testind = (ind == i); 
testind = replab(testind,Nfps);

[XTrain, YTrain, XTest, YTest] = gendata(Features,labels, testind);

disp('Training FFNN .....');
Mdl = fitcnet(XTrain',YTrain,"LayerSizes",256, "Standardize",true);

disp('Evaluating the model on test data .....');
predLabels = [];
for i = 1:numel(XTest)
    predLabels = [predLabels mode(predict(Mdl, XTest{i}'))];
end
Mmlp = Evaluate(YTest,predLabels);
stats_mlp = [stats_mlp Mmlp];

end

fprintf(' Classifier \t Recall \t Precision \t  F1-measure \t Accuracy \t  mcc \n');
disp('----------------------------------------------------------------------------------------------');
fprintf(' WSN \t\t %.2f \t\t %.2f \t\t %.2f \t\t %.2f \t\t %.2f \n', mean([stats_mlp.Recall])*100, mean([stats_mlp.Precision])*100,mean([stats_mlp.F1score])*100, mean([stats_mlp.Accuracy])*100, mean([stats_mlp.mcc]));
