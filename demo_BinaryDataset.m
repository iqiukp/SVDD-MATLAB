%{
    Demonstration of Binary Dataset
%}

clc
close all
addpath(genpath(pwd))

%
ocdata = BinaryDataset( 'shape', 'banana',...
                        'dimensionality', 2,...
                        'number', [100, 100],...
                        'display', 'on', ...
                        'noise', 0.2,...
                        'ratio', 0.3);

[data, label] = ocdata.generate;
[trainData, trainLabel, testData, testLabel] = ocdata.partition;
