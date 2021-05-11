%{
    Demonstration of dataset generation and partitioning.
%}

clc
clear all
close all
addpath(genpath(pwd))

% 2D banana-shaped dataset
[data_2D, label_2D] = DataSet.generate('dim', 2, 'num', [200, 200], 'display', 'on');

% 3D banana-shaped dataset
[data_3D, label_3D] = DataSet.generate('dim', 3, 'num', [200, 200], 'display', 'on');