classdef BaseSVDD < handle & matlab.mixin.Copyable
    %{
        CLASS DESCRIPTION

        Train and test SVDD model.
    
    -----------------------------------------------------------------
    
        Version 2.1, 11-MAY-2021
        Email: iqiukp@outlook.com
    -----------------------------------------------------------------
    %}
    
    properties
        data
        label
        cost = 0.9
        kernelFunc = Kernel('type', 'gaussian', 'gamma', 0.5)
        supportVectors
        supportVectorIndices
        numSupportVectors
        numIterations
        alpha
        alphaTolerance = 1e-6
        supportVectorAlpha
        radius
        offset
        distance
        predictedLabel
        runningTime
        boundary
        boundaryHandle
        display = 'on'
        optimization
        dimReduction
        crossValidation
        dataWeight
        performance
        evaluationMode = 'test'
    end
    
    properties (Dependent)
        dataType
        numSamples
        numFeatures
        numPositiveSamples
        numNegativeSamples
    end
    
    methods
        % create an object of SVDD
        function obj = BaseSVDD(parameter)
            SvddOption.setParameter(obj, parameter);
        end
        
        % train SVDD model
        function varargout = train(obj, varargin)
            tStart = tic;
            input_ = varargin;
            SvddOption.checkInputForTrain(obj, input_);

            % dimensionality reduction using PCA
            if strcmp(obj.dimReduction.switch, 'on')
                if obj.dimReduction.param > 1
                    [P, Z, ~, ~, ~, mu]  = pca(obj.data, 'NumComponents', obj.dimReduction.param);
                    obj.data = Z;
                    obj.dimReduction.pcaCoeff = P;
                    obj.dimReduction.pcaMu = mu;
                else
                    [P, Z, L, ~, ~, mu]  = pca(obj.data);
                    dim = find(cumsum(L/sum(L)) >= obj.dimReduction.param, 1, 'first');
                    obj.data = Z(:, 1:dim);
                    obj.dimReduction.pcaCoeff = P(:, 1:dim);
                    obj.dimReduction.pcaMu = mu;
                end
            end

            % parameter optimization
            if strcmp(obj.optimization.switch, 'on')
                SvddOptimization.getModel(obj);
            else
                getModel(obj);
            end

            % model evaluation
            display_ = obj.display;
            evaluationMode_ = obj.evaluationMode;
            obj.display = 'off';
            obj.evaluationMode = 'train';
            results_ = test(obj, obj.data, obj.label);
            obj.display = display_;
            obj.evaluationMode = evaluationMode_;
            obj.performance = evaluateModel(obj, results_);
            obj.distance = results_.distance;
            obj.predictedLabel = results_.predictedLabel;
            
            % cross validation
            if strcmp(obj.crossValidation.switch, 'on')
                svdd_ = copy(obj);
                obj.crossValidation.accuracy = SvddOptimization.crossvalFunc(svdd_);
            end
            obj.runningTime = toc(tStart); 
            % display
            if strcmp(obj.display, 'on')
                SvddOption.displayTrain(obj);
            end
            % output
            if nargout == 1
                varargout{1} = obj;
            end
        end
        
        function getModel(obj)
            K = obj.kernelFunc.computeMatrix(obj.data, obj.data);
            solveModel(obj, K);
        end
        
        function results = test(obj, varargin)
            tStart = tic; 
            input_ = varargin;
            results = SvddOption.checkInputForTest(input_);
            if strcmp(obj.dimReduction.switch, 'on') && strcmp(obj.evaluationMode, 'test')
                results.data = (results.data-obj.dimReduction.pcaMu)*obj.dimReduction.pcaCoeff;
            end
            results.radius = obj.radius;
            [results.numSamples, results.numFeatures] = size(results.data);
            K = obj.kernelFunc.computeMatrix(results.data, obj.data);
            K_ = obj.kernelFunc.computeMatrix(results.data, results.data);
            tmp_ = -2*sum((ones(results.numSamples, 1)*obj.alpha').*K, 2);
            results.distance = sqrt(diag(K_)+tmp_+obj.offset);
            results.predictedLabel = ones(results.numSamples, 1);
            results.predictedLabel(results.distance > obj.radius, 1) = -1;
            results.numAlarm = sum(results.predictedLabel == -1, 1);
            if strcmp(results.labelType, 'true')
                results.numPositiveSamples = sum(results.label == 1, 1);
                results.numNegativeSamples = sum(results.label == -1, 1);
                results.performance = evaluateModel(obj, results);
            end
            results.runningTime = toc(tStart); 
            % display
            if strcmp(obj.display, 'on')
                SvddOption.displayTest(results);
            end
        end
        
        function solveModel(obj, K)
            % Coefficient of Quadratic optimization
            % H: Symmetric Hessian matrix
            numSamples_ = size(K, 1);
            H = obj.label*obj.label'.*K;
            H = H+H';
            f = -obj.label.*diag(K);
            % Lower and upper bounds
            lb = zeros(numSamples_, 1);
            ub = ones(numSamples_, 1);
            switch obj.dataType
                case 'single'
                    if strcmp(obj.dataWeight.switch, 'on')
                        ub(obj.label==1, 1) = obj.cost(1, 1)*obj.dataWeight.param(obj.label==1, 1);
                    else
                        ub(obj.label==1, 1) = obj.cost(1, 1);
                    end
                    
                case 'hybrid'
                    if strcmp(obj.dataWeight.switch, 'on')
                        ub(obj.label==1, 1) = obj.cost(1, 1)*obj.dataWeight.param(obj.label==1, 1);
                        ub(obj.label==-1, 1) = obj.cost(1, 2)*obj.dataWeight.param(obj.label==-1, 1);
                    else
                        ub(obj.label==1, 1) = obj.cost(1, 1);
                        ub(obj.label==-1, 1) = obj.cost(1, 2);
                    end
            end
            % Linear Equality Constraint
            Aeq = obj.label';
            beq = 1;
            % Quadratic optimize
            opt = optimset('quadprog');
            opt.Algorithm = 'interior-point-convex';
%             opt.Algorithm = 'active-set';
            opt.Display = 'off';
            [obj.alpha, ~, ~, output, ~] = quadprog(H, f, [], [], Aeq, beq, lb, ub, [], opt);
            if (isempty(obj.alpha))
                warning('No solution for the SVDD model could be found.');
                obj.alpha = zeros(obj.numSamples, 1);
                obj.alpha(1, 1) = 1;
            end
            obj.alpha = obj.label.*obj.alpha;
            obj.numIterations = output.iterations;
            obj.supportVectorIndices = find(abs(obj.alpha) > obj.alphaTolerance);
            obj.boundary = obj.supportVectorIndices(find((obj.alpha(obj.supportVectorIndices) < ...
                ub(obj.supportVectorIndices))&(obj.alpha(obj.supportVectorIndices) > obj.alphaTolerance)));
            if (size(obj.boundary, 1) < 1)
                obj.boundary = obj.supportVectorIndices;
            end
            obj.alpha(find(abs(obj.alpha) < obj.alphaTolerance)) = 0;
            obj.supportVectors = obj.data(obj.supportVectorIndices, :);
            obj.supportVectorAlpha = obj.alpha(obj.supportVectorIndices);
            obj.numSupportVectors = size(obj.supportVectorIndices, 1);
            tmp_ = -2*sum((ones(numSamples_, 1)*obj.alpha').*K, 2);
            obj.offset = sum(sum((obj.alpha*obj.alpha').*K));
            obj.radius = sqrt(mean(diag(K))+obj.offset+mean(tmp_(obj.boundary, :)));
        end

        function performance = evaluateModel(~, results)
            performance.accuracy = sum(results.predictedLabel == results.label)/results.numSamples;
            [~, dis_index] = sort(results.distance, 'ascend');
            label_ = results.label(dis_index);
            if strcmp(results.dataType, 'hybrid')
                order_ = [1, -1];
                M = confusionmat(results.label',results.predictedLabel', 'order', order_);
                TP = M(1, 1);
                FP = M(2, 1);
                FN = M(1, 2);
                TN = M(2, 2);
                performance.FPR = cumsum(label_ == -1, 1)/results.numNegativeSamples;
                performance.TPR = cumsum(label_ == 1, 1)/results.numPositiveSamples;
                performance.AUC = trapz(performance.FPR, performance.TPR);
                performance.errorRate = (FP+FN)/(results.numSamples);
                performance.sensitive = TP/results.numPositiveSamples;
                performance.specificity = TN/results.numNegativeSamples;
                performance.precision = TP/(TP+FP);
                performance.recall = TP/results.numPositiveSamples;
            end
        end
        
        function numSamples = get.numSamples(obj)
            numSamples= size(obj.data, 1);
        end
        
        function numFeatures = get.numFeatures(obj)
            numFeatures= size(obj.data, 2);
        end
        
        function numPositiveSamples = get.numPositiveSamples(obj)
            numPositiveSamples = sum(obj.label == 1, 1);
        end
        
        function numNegativeSamples = get.numNegativeSamples(obj)
            numNegativeSamples = sum(obj.label == -1, 1);
        end
        
        function dataType = get.dataType(obj)
            tmp_ = unique(obj.label);
            switch length(tmp_)
                case 1
                    dataType = 'single';
                    if ~isequal(unique(obj.label), 1) && ~isequal(unique(obj.label), -1)
                        error('The label must be 1 (positive sample) or -1 (negative sample)')
                    end
                case 2
                    dataType = 'hybrid';
                    if ~isequal(unique(obj.label), [1; -1]) && ~isequal(unique(obj.label), [-1; 1])
                        error('The label must be 1 (positive sample) or -1 (negative sample)')
                    end
                otherwise
                    dataType = 'others';
            end
        end
    end
end