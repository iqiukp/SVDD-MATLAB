%{
    SVDD application for positive training data using 
        Dimensionality Reduction module.

    Notice:  
    
     (1)     Dimensionality Reduction is realized based on drtoolbox.
             For details about drtoolbox, please visit the website:
             http://lvdmaaten.github.io/drtoolbox/

%}

%%
clear all
close all
clc
addpath(genpath(pwd))

%% load training data and testing data
load('.\data\demoData.mat')

%% Dimensionality Reduction using drtoolbox
%{
------------------------------------------------------------------------
Notice:  

 (1)     Details please see the 'Readme.txt' file in the folder:
         '.\DimensionalityReduction\drtoolbox'  

 (2)     You can change the value of no_dims to the target dimensionality.

------------------------------------------------------------------------
%}
% take Isomap for example
% estimate the intrinsic dimensionality of trainData
no_dims = round(intrinsic_dim(trainData, 'MLE'));
% no_dims = 2;
[trainData, mapping] = compute_mapping(trainData, 'Isomap', no_dims);
testData = out_of_sample(testData, mapping);

%% creat an SVDD object                 
SVDD = Svdd('positiveCost', 0.9,...
            'kernel', Kernel('type', 'gauss', 'width', 16));
        
%% train and test SVDD model
% train an SVDD model 
model = SVDD.train(trainData, trainLabel);

% test SVDD model
result = SVDD.test(model,testData, testLabel);

%% Visualization
% plot the curve of testing result
Visualization.plotTestResult(model, result)


