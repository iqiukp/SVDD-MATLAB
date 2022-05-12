%{
    Demonstration of SVDD parameter optimization.
%}

clc
close all
addpath(genpath(pwd))

ocdata = BinaryDataset();
ocdata.generate;
[trainData, trainLabel, testData, testLabel] = ocdata.partition;

% set parameter
cost = 0.9;
kernel = BaseKernel('type', 'gaussian', 'gamma', 1.5);

% optimization setting 
opt.method = 'pso'; % bayes, ga  pso 
opt.variableName = { 'cost', 'gamma'};
opt.variableType = {'real', 'real'}; % 'integer' 'real'
opt.lowerBound = [10^-2, 2^-6];
opt.upperBound = [10^0, 2^6];
opt.maxIteration = 20;
opt.points = 3;
opt.display = 'on';

svddParameter = struct('cost', cost, ...
                       'kernelFunc', kernel, ...
                       'optimization', opt, ...
                       'KFold', 5);

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
