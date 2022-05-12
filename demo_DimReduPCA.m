%{
    Demonstration of SVDD model training with PCA.
%}

clc
close all
addpath(genpath(pwd))

ocdata = BinaryDataset( 'shape', 'circle',...
                        'dimensionality', 3,...
                        'number', [200, 200],...
                        'display', 'on', ...
                        'noise', 0.1,...
                        'ratio', 0.3);

[data, label] = ocdata.generate;
[trainData, trainLabel, testData, testLabel] = ocdata.partition;

% parameter setting
cost = 0.9;
kernel = BaseKernel('type', 'gaussian', 'gamma', 0.5);
svddParameter = struct('cost', cost,...
                       'kernelFunc', kernel,...
                       'PCA', 2);
               
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
