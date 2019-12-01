%{
    SVDD application for positive training data
%}

%%
clear all
clc
addpath(genpath(pwd))

%% load training data and testing data
load('.\data\demoData.mat')

%% creat an SVDD object
SVDD = Svdd('positiveCost', 0.9,...
            'kernel', Kernel('type', 'gauss', 'width', 16),...
            'option', struct('display', 'on'));
        
%% train and test SVDD model
% train an SVDD model 
model = SVDD.train(trainData, trainLabel);

% test the SVDD model
result = SVDD.test(model,testData, testLabel);

%% Visualization
% plot the curve of testing result
Visualization.plotTestResult(model, result)





