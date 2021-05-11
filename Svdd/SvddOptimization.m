classdef SvddOptimization < handle
    %{
        CLASS DESCRIPTION

        Parameter optimization for SVDD model.
    
    -----------------------------------------------------------------
    
        Version 1.1, 11-MAY-2021
        Email: iqiukp@outlook.com
    ------------------------------------------------------------------
    %}
    
    methods (Static)
        function svdd = getModel(svdd)
            objFun = @(parameter) SvddOptimization.getObjValue(parameter, svdd);
            svdd.optimization.numVariables = length(svdd.optimization.variableName);
            tmp_ = cell(1, svdd.optimization.numVariables);
            for i = 1:svdd.optimization.numVariables
                switch svdd.optimization.variableType{i}
                    case 'real'
                        tmp_{i} = 'double';
                    case 'integer'
                        tmp_{i} = 'int32';
                end
            end
            % 
            svdd.optimization.bestParam = array2table(zeros(1, size(svdd.optimization.lowerBound, 2)));
            svdd.optimization.bestParam.Properties.VariableNames = svdd.optimization.variableName;
            %
            switch svdd.optimization.method
                case 'bayes'
                    SvddOptimization.bayesopt(svdd, objFun);
                case 'ga'
                    SvddOptimization.gaopt(svdd, objFun);
                case 'pso'
                    SvddOptimization.psoopt(svdd, objFun);
            end
            % 
            SvddOptimization.setParameter(svdd);
            svdd.getModel;
        end
        
        function bayesopt(svdd, objFun)
            %{
                Optimize the parameters using Bayesian optimization.
                For detailed introduction of the algorithm and parameter
                setting, please enter 'help bayesopt' in the command line.
            %}
            parameter = [];
            % set variable range and type
            var_ = length(svdd.optimization.lowerBound);
            for i = 1:var_
                tmp_ = optimizableVariable(svdd.optimization.variableName{i},...
                    [svdd.optimization.lowerBound(i) svdd.optimization.upperBound(i)],...
                    'Type', svdd.optimization.variableType{i});
                parameter = [parameter, tmp_];
            end
            results = bayesopt(objFun, parameter, 'Verbose', 1,...
                'MaxObjectiveEvaluations', svdd.optimization.maxIteration,...
                'NumSeedPoints', svdd.optimization.points);
            % optimization results
            [svdd.optimization.bestParam, ~, ~] = bestPoint(results, 'Criterion', 'min-observed');
        end
        
        function gaopt(svdd, objFun)
            %{
                Optimize the parameters using Genetic Algorithm (GA)
                For detailed introduction of the algorithm and parameter
                setting, please enter 'help ga' in the command line.
            %}
            seedSize = 10*svdd.optimization.numVariables;
            try
                options = optimoptions('ga', 'PopulationSize', seedSize,...
                    'MaxGenerations', svdd.optimization.maxIteration,...
                    'Display', 'diagnose', 'PlotFcn', 'gaplotbestf');
                bestParam_ = ga(objFun, svdd.optimization.numVariables, [], [], [], [],...
                    svdd.optimization.lowerBound, svdd.optimization.upperBound, [], [], options);
            catch % older vision 
                options = optimoptions('ga', 'PopulationSize', seedSize,...
                    'MaxGenerations', svdd.optimization.maxIteration,...
                    'Display', 'diagnose', 'PlotFcn', @gaplotbestf);
                bestParam_ = ga(objFun, svdd.optimization.numVariables, [], [], [], [],...
                    svdd.optimization.lowerBound, svdd.optimization.upperBound, [], [], options);
            end
            % optimization results
            svdd.optimization.bestParam.Variables = bestParam_;
        end

        function psoopt(svdd, objFun)
            %{
                Optimize the parameters using Particle Swarm Optimization (PSO)
                For detailed introduction of the algorithm and parameter
                setting, please enter 'help particleswarm' in the command line.
            %}
            seedSize = 10*svdd.optimization.numVariables;
            options = optimoptions('particleswarm', 'SwarmSize', seedSize,...
                'MaxIterations', svdd.optimization.maxIteration,...
                'Display', 'iter', 'PlotFcn', 'pswplotbestf');
            bestParam_ = particleswarm(objFun, svdd.optimization.numVariables,...
                svdd.optimization.lowerBound, svdd.optimization.upperBound, options);
            % optimization results
            svdd.optimization.bestParam.Variables = bestParam_;
        end
        
        function objValue = getObjValue(parameter, svdd)
            %{
                Compute the value of objective function
            %}
            svdd_ = copy(svdd);
            svdd_.display = 'off';
            switch class(parameter)
                case 'table' % bayes
                    svdd_.optimization.bestParam = parameter;
                case 'double' % ga, pso
                    svdd_.optimization.bestParam.Variables = parameter;
            end
            % parameter setting
            SvddOptimization.setParameter(svdd_);
            % cross validation
            if strcmp(svdd_.crossValidation.switch, 'on')
                objValue = 1-SvddOptimization.crossvalFunc(svdd_);
            else
                % train with all samples
                svdd_.getModel;
                svdd_.evaluationMode = 'train';
                results_ = test(svdd_, svdd_.data, svdd_.label);
                svdd_.performance = svdd_.evaluateModel(results_);
                objValue = 1-svdd_.performance.accuracy;
            end
        end

        function accuracy = crossvalFunc(svdd)
            %{
                Compute the cross validation accuracy
            %}
            rng('default')
            svdd_ = copy(svdd);
            data_ = svdd_.data;
            label_ = svdd_.label;
            svdd_.display = 'off';
            svdd_.evaluationMode = 'train';
            cvIndices = crossvalind(svdd.crossValidation.method, ...
                svdd_.numSamples, svdd.crossValidation.param);
            switch svdd.crossValidation.method
                case 'KFold'
                    accuracy_ = Inf(svdd.crossValidation.param, 1);
                    for i = 1:svdd.crossValidation.param
                        testIndices = (cvIndices == i);
                        testData = data_(testIndices, :);
                        testLabel = label_(testIndices, :);
                        svdd_.data = data_(~testIndices, :);
                        svdd_.label = label_(~testIndices, :);
                        try
                            svdd_.getModel;
                        catch
                            continue
                        end
                        results = svdd_.test(testData, testLabel);
                        accuracy_(i, 1) = results.performance.accuracy;
                    end
                    accuracy_(accuracy_ == Inf) = [];
                    accuracy = mean(accuracy_);
                    
                case 'Holdout'
                    testIndices = (cvIndices == 0);
                    testData = data_(testIndices, :);
                    testLabel = label_(testIndices, :);
                    svdd_.data = data_(~testIndices, :);
                    svdd_.label = label_(~testIndices, :);
                    svdd_.getModel;
                    results = svdd_.test(testData, testLabel);
                    accuracy = results.performance.accuracy;
            end
        end
        
        function setParameter(svdd)
            %{
                Supported parameter: cost, degree, offset, gamma
            %}
            name_ = svdd.optimization.bestParam.Properties.VariableNames;
            for i = 1:length(name_)
                switch name_{i}
                    case 'cost' % SVDD parameter
                        svdd.cost(1) = svdd.optimization.bestParam.cost;
                    case {'degree', 'offset', 'gamma'} % kernel function parameter
                        svdd.kernelFunc.(name_{i}) = svdd.optimization.bestParam.(name_{i});
                end
            end
        end
    end
end