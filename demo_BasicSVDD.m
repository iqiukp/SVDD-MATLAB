%{
    Demonstration of basic SVDD model.
%}

clc
close all
addpath(genpath(pwd))

% generate dataset
ocdata = BinaryDataset();
ocdata.generate;
[trainData, trainLabel, testData, testLabel] = ocdata.partition;

% set parameter
cost = 0.9;
kernel = BaseKernel('type', 'gaussian', 'gamma', 1.5);
svddParameter = struct('cost', cost, 'kernelFunc', kernel);

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

