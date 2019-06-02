% DESCRIPTION
% Fault detection based on Support Vector Data Description
%
%
% ---------------------------------------------------------------------%

clc
close all
% clearvars
addpath(genpath(pwd))

% Load  data (X: training data  Y: testing data)
load ('.\data\X.mat')
load ('.\data\Y.mat')

% Normalization (in general, this step is important for fault detection)
[X_s,Y_s] = normalize(X,Y);

% Set parameters 
C = 0.5;   % trade-off parameter
s = 9;     % kernel width
ker = struct('type','gauss','width',s);

% Train SVDD hypersphere
model = svdd_train(X_s,C,ker);

% Test a new sample Y (vector of matrix)
d = svdd_test(model,Y_s);

% Plot the results
plotResult(model.R,d)

