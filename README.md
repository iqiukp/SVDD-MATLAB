# Support Vector Data Description (SVDD)

MATLAB Code for abnormal detection or fault detection using SVDD.

Version 2.0, 1-DEC-2019
    
Email: iqiukp@outlook.com

-------------------------------------------------------------------

## Main features

* SVDD model for training dataset containing only positive training data. (SVDD)
* SVDD model for training dataset containing both positive training data and negative training data. (nSVDD)
* Multiple kinds of kernel functions.
* Visualization module including ROC curve plotting, testing result plottong, and decision boundary.
* Dimensionality Reduction (DR) module based on ['drtoolbox'](http://lvdmaaten.github.io/drtoolbox).
* Parameter Optimization (PO) module based on the ['YPEA' toolbox](https://yarpiz.com/477/ypea-yarpiz-evolutionary-algorithms?tdsourcetag=s_pctim_aiomsg).
* Preprocessing module for data standardization or data normalization.
-------------------------------------------------------------------

## About SVDD model

Two types of SVDD modles are built according to the following references:

[1]    Tax D M J, Duin R P W. Support vector data description[J]. Machine learning, 2004, 54(1): 45-66.

-------------------------------------------------------------------

## About demonstrations

A total of 9 demonstrations were provided, as follows:

1. demo_KernelMatrix

   Demonstration for kernel function, including:
        
      (1) gaussian kernel function (gauss): k(x,y) = exp(-(norm(x-y)/s)^2)
      
      (2) exponential kernel function (exp): k(x,y) = exp(-(norm(x-y))/s^2)
      
      (3) linear kernel function (linear): k(x,y) = x'*y
      
      (4) laplacian kernel function (lapl): k(x,y) = exp(-(norm(x-y))/s)
      
      (5) sigmoid kernel function (sigm): k(x,y) = tanh(g*x'*y+c)
      
      (6) polynomial kernel function (poly): k(x,y) = (x'*y+c)^d

2. demo_SVDD

   SVDD application for positive training data
        
3. demo_SVDD_PO

   SVDD application for positive training data using Parameter Optimization module.

4. demo_SVDD_DR

   SVDD application for positive training data using Dimensionality Reduction module.

5. demo_SVDD_DR_PO

   SVDD application for positive training data using Dimensionality Reduction module and Parameter Optimization module.

6. demo_nSVDD

   SVDD application for positive training data and negative trainingdata.
        
7. demo_nSVDD_PO

   SVDD applicationfor positive training data and negative training data using Parameter Optimization module.

8. demo_nSVDD_DR

   SVDD application for positive training data and negative training data using Dimensionality Reduction module.

9. demo_nSVDD_DR_PO

   SVDD applicationfor positive training data and negative training data using Parameter Optimization module and Dimensionality     Reduction module.
-------------------------------------------------------------------

## About Dimensionality Reduction (DR) module

Dimensionality Reduction module is realized based on 'drtoolbox', contains Matlab implementations of 34 techniques for dimensionality reduction and metric learning. 

For details about 'drtoolbox', please visit the website: http://lvdmaaten.github.io/drtoolbox 

-------------------------------------------------------------------

## About Parameter Optimization (PO) module

Parameter Optimization module is realized based on on the YPEA toolbox, contains Matlab implementations of 14 techniques for Parameter Optimization and metric learning. 

For details about YPEA toolbox, please visit the website: https://yarpiz.com/477/ypea-yarpiz-evolutionary-algorithms?tdsourcetag=s_pctim_aiomsg

-------------------------------------------------------------------

## A simple application

```

%{
    SVDD application for positive training data and negative training data.
%}


clear all
close all
clc
addpath(genpath(pwd))

%% load training data and testing data
[trainData, trainLabel, testData, testLabel] = prepareData('banana');

%% creat an SVDD object                 
SVDD = Svdd('positiveCost', 0.7,...
            'negativeCost', 0.9,...
            'kernel', Kernel('type', 'gauss', 'width', 5));
        
%% train and test SVDD model
% train an SVDD model 
model = SVDD.train(trainData, trainLabel);

% test SVDD model
result = SVDD.test(model,testData, testLabel);

%% Visualization
% plot the curve of testing result
Visualization.plotTestResult(model, result)
% plot the ROC curve
Visualization.plotROC(testLabel, result.distance);
% plot the decision boundary
Visualization.plotDecisionBoundary(SVDD, model, trainData, trainLabel);

```

* decision boundary

<img src="https://github.com/iqiukp/Support-Vector-Data-Description-SVDD/blob/master/img/contour.png" width="480"><img src="https://github.com/iqiukp/Support-Vector-Data-Description-SVDD/blob/master/img/decision-boundary.png" width="480">

* testing result

<img src="https://github.com/iqiukp/Support-Vector-Data-Description-SVDD/blob/master/img/distance.png" width="480">

* ROC curve

<img src="https://github.com/iqiukp/Support-Vector-Data-Description-SVDD/blob/master/img/ROC.png" width="480">
