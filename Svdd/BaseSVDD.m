classdef BaseSVDD < handle & matlab.mixin.Copyable
    %{
        Abnormal detection using Support Vector Data Description (SVDD).

        Email: iqiukp@outlook.com

        -------------------------------------------------------------
  
        Version 2.2, 13-MAY-2022
            -- Added support for hybrid-kernel SVDD. 
                 K =w1*K1+w2*K2+...+wn*Kn
            -- Added support for output of optimization results.
            -- Improved visualization of parameter optimization.
            -- Fixed minor bugs.

        Version 2.1, 21-MAY-2021
            -- Fixed minor bugs.
            -- Added support for parameter optimization using Bayesian 
               optimization, genetic algorithm, and particle swarm optimizatio.
            -- Added support for weighted SVDD. 

        Version 2.0, 27-MAR-2020
            -- Fixed minor bugs.
            -- Added support for negative SVDD.   

        Version 1.0, 1-NOV-2018
            -- First release.

        -------------------------------------------------------------
        
        BSD 3-Clause License
        Copyright (c) 2022, Kepeng Qiu
        All rights reserved.
    %}
    
    properties
        data
        label
        cost = 0.9
        kernelFunc = BaseKernel('type', 'gaussian', 'gamma', 0.5)
        supportVectors
        supportVectorIndices
        numSupportVectors
        numIterations
        numKernel
        alpha
        alphaTolerance = 1e-6
        supportVectorAlpha
        radius
        offset
        distance
        predictedLabel
        elapsedTime
        boundary
        display = 'on'
        optimization
        dimReduction
        crossValidation
        dataWeight
        featureWeight
        performance
        evaluationMode = 'test'
        kernelWeight
        kernelFuncName
        kernelType
        boundaryHandle
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
            setParameter(obj, parameter);
        end
        
        % train SVDD model
        function varargout = train(obj, varargin)
            tStart = tic;
            input_ = varargin;
            checkInputForTrain(obj, input_);

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
            obj.elapsedTime = toc(tStart); 
            % display
            if strcmp(obj.display, 'on')
                displayTrain(obj);
            end
            % output
            if nargout == 1
                varargout{1} = obj;
            end
        end
        
        function getModel(obj)
            switch obj.kernelType
                case 'single'
                    K = obj.kernelFunc.computeMatrix(obj.data, obj.data);
                case 'hybrid'
                    K = 0;
                    for i = 1:obj.numKernel
                        K = K+obj.kernelWeight(i)*obj.kernelFunc(i).computeMatrix(obj.data, obj.data);
                    end
            end
            solveModel(obj, K);
        end
        
        function results = test(obj, varargin)
            tStart = tic; 
            input_ = varargin;
            results = checkInputForTest(obj, input_);
            if strcmp(obj.dimReduction.switch, 'on') && strcmp(obj.evaluationMode, 'test')
                results.data = (results.data-obj.dimReduction.pcaMu)*obj.dimReduction.pcaCoeff;
            end
            results.radius = obj.radius;
            [results.numSamples, results.numFeatures] = size(results.data);

            switch obj.kernelType
                case 'single'
                    K = obj.kernelFunc.computeMatrix(results.data, obj.data);
                case 'hybrid'
                    K = 0;
                    for i = 1:obj.numKernel
                        K = K+obj.kernelWeight(i)*obj.kernelFunc(i).computeMatrix(results.data, obj.data);
                    end
            end

            switch obj.kernelType
                case 'single'
                    K_ = obj.kernelFunc.computeMatrix(results.data, results.data);
                case 'hybrid'
                    K_ = 0;
                    for i = 1:obj.numKernel
                        K_ = K_+obj.kernelWeight(i)*obj.kernelFunc(i).computeMatrix(results.data, results.data);
                    end
            end

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
                displayTest(obj, results);
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
%                 warning('No solution for the SVDD model could be found.');
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
        
        function checkInputForTrain(obj, input_)
            numInput = length(input_);
            switch numInput
                case 1
                    obj.data = input_{1};
                    obj.label = ones(size(input_{1}, 1), 1);
                case 2
                    obj.data = input_{1};
                    obj.label = input_{2};
                otherwise
                    errorText = sprintf([
                        'Incorrected input number.\n',...
                        'svdd.train(data).\n', ...
                        'svdd.train(data, label).']); 
                    error(errorText)
            end

            switch obj.dataType
                case 'single'
                    if ~isequal(unique(obj.label), 1) && ~isequal(unique(obj.label), -1)
                        error('The label must be 1 for positive sample or -1 for negative sample.')
                    end
                case 'hybrid'
                    % the negetive cost is set to a constant related to the number of negetive samples. 
                    obj.cost = [obj.cost, 2/obj.numNegativeSamples];
                    if ~isequal(unique(obj.label), [1; -1]) && ~isequal(unique(obj.label), [-1; 1])
                        error('The label must be 1 for positive sample or -1 for negative sample.')
                    end
                case 'others'
                    error('SVDD is only supported for one-class or binary classification.')
            end

            obj.numKernel = numel(obj.kernelFunc);
            for i = 1:obj.numKernel
                obj.kernelFuncName{i, 1} = obj.kernelFunc(i).type;
            end
            if obj.numKernel == 1
                obj.kernelType = 'single';
                obj.kernelFuncName{1} = obj.kernelFunc.type;
            else
                obj.kernelType = 'hybrid';
                for i = 1:obj.numKernel
                    obj.kernelFuncName{i, 1} = obj.kernelFunc(i).type;
                end
            end
            if isempty(obj.kernelWeight)
                obj.kernelWeight = 1/obj.numKernel*ones(obj.numKernel, 1);
            end

            if strcmp(obj.optimization.switch, 'on')
                if strcmp(obj.kernelFunc.type, 'polynomial')
                    if ~strcmp(obj.optimization.method, 'bayes')
                        error('The parameter of the polynomial kernel funcion should be optimized by Bayesian optimization.')
                    end
                end
            end

        end

        function results = checkInputForTest(~, input_)
            numInput = length(input_);
            switch numInput
                case 1
                    results.data = input_{1};
                    results.label = ones(size(results.data, 1), 1);
                    results.labelType = 'false';
                case 2
                    results.data = input_{1};
                    results.label = input_{2};
                    results.labelType = 'true';
                otherwise
                    errorText = sprintf([
                        'Incorrected input number.\n',...
                        'svdd.test(data).\n', ...
                        'svdd.test(data, label).']); 
                    error(errorText)
            end
            tmp_ = unique(results.label);
            switch length(tmp_)
                case 0
                    results.dataType = 'unknown';
                case 1
                    results.dataType = 'single';
                    if ~isequal(tmp_, 1) && ~isequal(tmp_, -1)
                        error('The label must be 1 (positive sample) or -1 (negative sample)')
                    end
                case 2
                    results.dataType = 'hybrid';
                    if ~isequal(tmp_, [1; -1]) && ~isequal(tmp_, [-1; 1])
                        error('The label must be 1 (positive sample) or -1 (negative sample)')
                    end
                otherwise
                    error('SVDD is only supported for one-class and binary classification.')
            end
        end
        
        function setParameter(obj, parameter)
            version_ = version('-release');
            year_ = str2double(version_(1:4));
            if year_ < 2016 || (year_ == 2016 && version_(5) == 'a')
                error('SVDD V2.1 is not compatible with the versions lower than R2016b.')
            end
            %
            obj.crossValidation.switch = 'off'; 
            obj.optimization.switch = 'off';
            obj.dimReduction.switch = 'off';
            obj.dataWeight.switch = 'off';
            name_ = fieldnames(parameter);
            for i = 1:size(name_, 1)
                switch name_{i}
                    case {'Holdout', 'KFold', 'Leaveout'}
                        obj.crossValidation.switch = 'on';
                        obj.crossValidation.method = name_{i, 1};
                        obj.crossValidation.param = parameter.(name_{i, 1});
                        
                    case {'optimization'}
                        obj.(name_{i}) = parameter.(name_{i, 1});
                        obj.(name_{i}).switch = 'on';
                        
                    case {'PCA'}
                        obj.dimReduction.switch = 'on';
                        obj.dimReduction.method = name_{i, 1};
                        obj.dimReduction.param = parameter.(name_{i, 1});
                        
                    case {'weight'}
                        obj.dataWeight.switch = 'on';
                        obj.dataWeight.param = parameter.(name_{i, 1});
                        
                    otherwise
                        obj.(name_{i, 1}) = parameter.(name_{i, 1});
                end
            end
        end
        
        function displayTrain(obj)
            fprintf('\n')
            fprintf('*** SVDD model training finished ***\n')
            fprintf('elapsed time            = %.4f seconds\n', obj.elapsedTime)
            fprintf('iterations              = %d \n', obj.numIterations)
            fprintf('number of samples       = %d \n', obj.numSamples)
            fprintf('number of SVs           = %d \n', obj.numSupportVectors)
            fprintf('ratio of SVs            = %.4f%% \n', 100*obj.numSupportVectors/obj.numSamples)
            fprintf('accuracy                = %.4f%%\n', 100*obj.performance.accuracy)
            if strcmp(obj.crossValidation.switch, 'on')
                tmp_1 = '(';
                tmp_2 = obj.crossValidation.method;
                tmp_3 = ', ';
                tmp_4 = num2str(obj.crossValidation.param);
                tmp_5 = ')';
                tmp_ = [tmp_1, tmp_2, tmp_3, tmp_4, tmp_5];
                tmp = ['CV accuracy ', tmp_, '  = %.4f%%\n'];
                fprintf(tmp, 100*obj.crossValidation.accuracy)
            end
            if strcmp(obj.optimization.switch, 'on')
                fprintf(['Parameter Optimization results using ', obj.optimization.method, '.\n'])
                disp(obj.optimization.bestParam)
                fprintf('\n')
            end
        end
        
        function displayTest(~, results)
            fprintf('\n')
            fprintf('*** SVDD model test finished ***\n')
            fprintf('elapsed time            = %.4f seconds\n', results.runningTime)
            fprintf('number of samples       = %d \n', results.numSamples)
            fprintf('number of alarm points  = %d \n', results.numAlarm)
            if strcmp(results.labelType, 'true')
                fprintf('accuracy                = %.4f%%\n', 100*results.performance.accuracy)
            end
        end


        % -------------------------------------------------------------%
        % dependent properties
        
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
