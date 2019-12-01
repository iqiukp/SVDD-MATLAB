classdef Preprocessing < handle
%{ 
    CLASS DESCRIPTION

-------------------------------------------------------------%
%} 
        methods(Static)
            
            % normalize the training data and testing data
            function [trainData, testData] = normalize(trainData, testData, varargin)
                [trainData, testData] = normalize(trainData, testData, varargin);
            end

            % standardize the training data and testing data
            function [trainData, testData] = standardize(trainData, testData)
                [trainData, testData] = standardize(trainData, testData);
            end
        end
end

