%{
    Demonstration of SVDD model training with hybrid kernel functions.
%}

clc
close all
addpath(genpath(pwd))

% generate dataset
ocdata = BinaryDataset( 'shape', 'circle',...
                        'dimensionality', 2,...
                        'number', [300, 300],...
                        'display', 'on', ...
                        'noise', 0.2,...
                        'ratio', 0.4);
[data, label] = ocdata.generate;
[trainData, trainLabel, testData, testLabel] = ocdata.partition;

% parameter setting
kernel_1 = BaseKernel('type', 'gaussian', 'gamma', 1);
kernel_2 = BaseKernel('type', 'polynomial', 'degree', 3);
kernelWeight = [0.5, 0.5];
cost = 0.9;

svddParameter = struct('cost', cost,...
                       'kernelFunc', [kernel_1, kernel_2],...
                       'kernelWeight', kernelWeight);

% creat an SVDD object
svdd = BaseSVDD(svddParameter);
% train SVDD model
svdd.train(trainData, trainLabel);
% test SVDD model
results = svdd.test(testData);

% Visualization 
svplot = SvddVisualization();
svplot.boundary(svdd);
svplot.distance(svdd, results);
