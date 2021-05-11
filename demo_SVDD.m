%{
    Demonstration of SVDD model training with only positive samples.
%}

clc
clear all
close all
addpath(genpath(pwd))

% training data and test data
[data, label] = DataSet.generate('dim', 3, 'num', [200, 200], 'display', 'off');
[trainData, trainLabel, testData, testLabel] = DataSet.partition(data, label, 'type', 'single');

% parameter setting
kernel = Kernel('type', 'gaussian', 'gamma', 0.04);
cost = 0.3;
svddParameter = struct('cost', cost,...
                       'kernelFunc', kernel);
               
% creat an SVDD object
svdd = BaseSVDD(svddParameter);
% train SVDD model
svdd.train(trainData, trainLabel);
% test SVDD model
results = svdd.test(testData, testLabel);

% Visualization 
svplot = SvddVisualization();
svplot.boundary(svdd);
svplot.distance(svdd, results);
svplot.testDataWithBoundary(svdd, results);
