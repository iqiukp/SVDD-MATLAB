classdef SvddTest < SvddTestBase
    methods
        function result = test(~, obj, model, testData, testLabel)
        %{

        DESCRIPTION
           Test the testing samples using the SVDD model


              result = test(~, obj, model, testData, testLabel)

                INPUT
                  obj         SVDD object
                  model       SVDD model
                  testData    testing data
                  testLabel   testing label

                OUTPUT
                  result      testing result
            
        Created on 29th November 2019 by Kepeng Qiu.
        -------------------------------------------------------------%

        %}
           
            % number of testing data
            N = size(testData, 1);
            % compute the kernel matrix
            
            K = obj.kernel.getKernelMatrix(testData, model.data);
            % the 1st term
            term1 = obj.kernel.getKernelMatrix(testData, testData);
            % the 2nd term
            term2 = repmat(-2*K*(model.alf.*model.label),1 , N);
            % the 3rd term
            term3 = model.term3;
            % distance
            distance = diag(term1+term2+term3);
            
            % predicted label
            predictedlabel = ones(N, 1);
            predictedlabel(distance>model.radius, 1) = -1;
            
            % compute prediction accuracy
            accuracy = sum(predictedlabel == testLabel)/N;
            
            % store the testing results
            result.accuracy = accuracy;
            result.distance = distance;
            result.predictedlabel = predictedlabel;
            result.testLabel = testLabel;
            if strcmp(obj.option.display, 'on')
                fprintf('\n')
                fprintf('*** Prediction finished ***\n')
                fprintf('accuracy = %.2f%% \n', 100*result.accuracy)
                fprintf('\n')
            end
        end
    end
end
