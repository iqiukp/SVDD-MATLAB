%{
    Demonstration of observation-weighted SVDD model.
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

%{
   Here, 'weight' is just used as an example, you can define a 
   weight vector (m*1). The size of 'weigh' should be m×1, 
   where m is the number of training samples.
%}
weight = rand(size(trainData, 1), 1);
svddParameter = struct('cost', cost, ...
                       'kernelFunc', kernel, ...
                       'weight', weight);

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
