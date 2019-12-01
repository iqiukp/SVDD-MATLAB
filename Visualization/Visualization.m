classdef Visualization < handle
%{ 
    CLASS DESCRIPTION


-------------------------------------------------------------%
%} 
        methods(Static)
                               
            % plot the ROC curve
            function [AUC, FPR, TPR] = plotROC(label, distance)
                [AUC, FPR, TPR] = plotROC(label, distance);
            end
            
            % plot the decision boundary
            function plotDecisionBoundary(SVDD, model, trainData, trainLabel)
                plotDecisionBoundary(SVDD, model, trainData, trainLabel);
            end
            
            % plot the curve of testing result
            function plotTestResult(model, result)
                plotTestResult(model, result);
            end
            
        end

end

