function [trainData, testData] = normalize(trainData, testData, varargin)
    %{ 
        DESCRIPTION
            normalize the training data and testing data

              [trainData, testData] = normalize(trainData, testData)
              [trainData, testData] = normalize(trainData, testData, minValue, maxValue)

        INPUT
          trainData            training data (N*d)
                               N: number of samples
                               d: number of features
          testData             testing data (N*d)
                               N: number of samples
                               d: number of features

          minValue             min value of normalization
                               default value: 0
          maxValue             max value of normalization
                               default value: 1

        OUTPUT
          trainData            normalized training data
          testData             normalized testing data (N*d)

        Created on 1st December 2019 by Kepeng Qiu.
        -------------------------------------------------------------%
    %} 


    % parameter setting
    if numel(varargin) == 0
        minValue = 0;
        maxValue = 1;
    elseif numel(varargin) == 2
        minValue = varargin{1};
        maxValue = varargin{2};
        if minValue >= maxValue
            error('The max value should be more than the min value.')
        end
    else
        error('Please enter the correct number of parameters.')
    end

    % normalize the training data and testing data
    x1 = trainData';
    [y1, PS] = mapminmax(x1, minValue, maxValue );
    x2 = testData';
    y2 = mapminmax('apply', x2, PS);

    trainData = y1';
    testData = y2';
end