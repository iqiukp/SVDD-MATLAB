% DESCRIPTION
% Industrial process fault detection based on SVDD (dd_tools)
% Given the train dataset X with kernel function type and
% its parameters, the resulting weights ALF,threshold, support vectors,and
% the indices of support vectors I are returned by 'svdd_train.m'. For a
% new sample, the resulting distance is  returned by 'svdd_test.m'. The
% result of fault detection can be visualized by 'plotResult.m'.
% Created on 1st November, 2018, by Kepeng Qiu.

% Demo2: Industrial process fault detection
% X:traindata
% Y:testdata (fault data)
% Improve monitoring performance by adjusting parameters simgma and C.

% ---------------------------------------------------------------------%
% Initialization
clc
clear 
close all
addpath(genpath(pwd))

% Load industrial process data 
% rows: samples;  columns: process variables
load X;
load Y;

% Normalization
mu = mean(X);
st = std(X);
X = zscore(X);
Y = (Y-mu)./st;

% Kernel function (description in 'computeKernelMatrix.m')
sigma = 8; % kernel width
ker = struct('type','gauss','width',sigma);
C = 0.05;  % fault tolerance rate

% Train SVDD hypersphere
model = svdd_train(X,C,ker);
% Test a new sample Y (vector of matrix)
d = svdd_test(model,Y);

% Plot the result
plotResult(model.threshold,d)