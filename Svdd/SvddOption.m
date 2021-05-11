classdef SvddOption < handle
    %{
        CLASS DESCRIPTION

        Option of SVDD model
    
    -----------------------------------------------------------------
    %}
    methods(Static) 
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
            if strcmp(obj.kernelFunc.type, 'polynomial')
                if strcmp(obj.optimization.switch, 'on')
                    if ~strcmp(obj.optimization.method, 'bayes')
                        error('The parameter of the polynomial kernel funcion should be optimized by Bayesian optimization.')
                    end
                end
            end
        end

        function results = checkInputForTest(input_)
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
            fprintf('running time            = %.4f seconds\n', obj.runningTime)
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
                fprintf('Optimized parameter')
                display(obj.optimization.bestParam)
                fprintf('\n')
            end
            if obj.numSupportVectors/obj.numSamples > 0.5
                warning('The trained SVDD model may be overfitting.')
            end
            fprintf('\n')
        end
        
        function displayTest(results)
            fprintf('\n')
            fprintf('*** SVDD model test finished ***\n')
            fprintf('running time            = %.4f seconds\n', results.runningTime)
            fprintf('number of samples       = %d \n', results.numSamples)
            fprintf('number of alarm points  = %d \n', results.numAlarm)
            if strcmp(results.labelType, 'true')
                fprintf('accuracy                = %.4f%%\n', 100*results.performance.accuracy)
            end
            fprintf('\n')
        end
    end
end