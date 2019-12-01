classdef Svdd < handle
%{ 
    CLASS DESCRIPTION


    Created on 1st December 2019 by Kepeng Qiu.
-------------------------------------------------------------%
%} 

    properties
        svddType            % SVDD type 
        positiveCost        % positive cost
        negativeCost        % negative cost
        kernel              % kernel function
        labelType           % label type: 'single' or 'hybrid' 
        option              % SVDD option
    end
        
    methods
        
        % create an object of SVDD
        function obj = Svdd(varargin)
            inputValue = varargin;
            checkResult = SvddFunction.checkInput(inputValue);
            fieldName = fieldnames(checkResult);
            for i = 1:numel(fieldName)
                obj.(fieldName{i, 1}) = checkResult.(fieldName{i, 1});
            end
        end

        % train SVDD model 
        function model = train(obj, data, label)
            obj.labelType = SvddFunction.getLabelType(label);
            trainType = SvddTrainBase.setFunction(obj.svddType);
            model = trainType.train(obj, data, label);
        end
        
        % test SVDD model 
        function result = test(obj, model, testData, testLabel)
            testType = SvddTestBase.setFunction(obj.svddType);
            result = testType.test(obj, model, testData, testLabel);
        end
    end
end


