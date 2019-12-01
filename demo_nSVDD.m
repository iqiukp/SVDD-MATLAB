%{
    SVDD application for positive training data and negative training data.
%}


clear all
close all
clc
addpath(genpath(pwd))

%% load training data and testing data
[trainData, trainLabel, testData, testLabel] = prepareData('banana');

%% creat an SVDD object                 
SVDD = Svdd('positiveCost', 0.7,...
            'negativeCost', 0.9,...
            'kernel', Kernel('type', 'gauss', 'width', 5));
        
%% train and test SVDD model
% train an SVDD model 
model = SVDD.train(trainData, trainLabel);

% test SVDD model
result = SVDD.test(model,testData, testLabel);

%% Visualization
% plot the curve of testing result
Visualization.plotTestResult(model, result)
% plot the ROC curve
Visualization.plotROC(testLabel, result.distance);
% plot the decision boundary
Visualization.plotDecisionBoundary(SVDD, model, trainData, trainLabel);



