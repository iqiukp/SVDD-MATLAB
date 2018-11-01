% DESCRIPTION
% Industrial process fault detection based on SVDD (dd_tools)
% Given the train dataset X with kernel function type and
% its parameters, the resulting weights ALF,threshold, support vectors,and
% the indices of support vectors I are returned by 'svdd_train.m'. For a
% new sample, the resulting distance is  returned by 'svdd_test.m'. The
% result of fault detection can be visualized by 'plotResult.m'.
% Created on 1st November, 2018, by Kepeng Qiu.

% Demo1: Random vectors from the multivariate normal distribution
% X:traindata
% Y:testdata 

% ---------------------------------------------------------------------%

% Initialization
clc
clear 
close all
addpath(genpath(pwd))

% Generate training data and test data
n = 3; % characteristic dimension of the samples
mu = zeros(n,1);
sigma = diag(ones(1,n));
n1 = 100;   % number of training data
n2 = 100;  % number of test data
data = mvnrnd(mu,sigma,n1+n2);
X = data(1:n1, :);          % training data
Y = data(n1+1:n1+n2, :);  % test data

% Kernel function (description in 'computeKernelMatrix.m')
sigma = 5; % kernel width
ker = struct('type','gauss','width',sigma);
C = 0.05;  % fault tolerance rate

% Train SVDD hypersphere
model = svdd_train(X,C,ker);
% Test a new sample Y (vector of matrix)
d = svdd_test(model,Y);

% Plot the result
plotResult(model.threshold,d)
