classdef SvddOptimization < handle   
    %{
        Parameter optimization for SVDD model

        Version 1.1, 13-MAY-2022
        Email: iqiukp@outlook.com

        ------------------------------------------------------------
        
        BSD 3-Clause License
        Copyright (c) 2022, Kepeng Qiu
        All rights reserved.
    %}


    methods (Static)
        function svdd = getModel(svdd)
            objFunc = @(parameter) SvddOptimization.getObjValue(parameter, svdd);
            SvddOptimization.checkParameter(svdd);
            svdd.optimization.bestParam = array2table(zeros(1, size(svdd.optimization.lowerBound, 2)));
            svdd.optimization.bestParam.Properties.VariableNames = svdd.optimization.variableName;
          
            % temporary variables for visualization
            optimization_.line = [];
            optimization_.startTime = tic;
            optimization_.totalElapsedTime = [];
            optimization_.objFuncValues = [];
            assignin('base', 'optimization_', optimization_)
            % 
            switch svdd.optimization.method
                case 'bayes'
                    SvddOptimization.bayesopt(svdd, objFunc);
                case 'ga'
                    SvddOptimization.gaopt(svdd, objFunc);
                case 'pso'
                    SvddOptimization.psoopt(svdd, objFunc);
            end
            % 
            SvddOptimization.setParameter(svdd);
            svdd.getModel;
            optimization_ = evalin('base', 'optimization_');
            svdd.optimization.objFuncValues = optimization_.objFuncValues;
            svdd.optimization.totalElapsedTime = optimization_.totalElapsedTime;
            evalin('base', 'clear optimization_');
        end
        
        function bayesopt(svdd, objFunc)
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
            % setting of display
            switch svdd.optimization.display
                case 'on'
                    plotFcn = @plotObjectiveModel;
                    outputFunc = @SvddOptimization.outputFunc;
                    verbose_ = 1;
                case 'off'
                    plotFcn = [];
                    outputFunc = {};
                    verbose_ = 0;
            end
            results = bayesopt(objFunc, parameter, 'Verbose', verbose_,...
                'MaxObjectiveEvaluations', svdd.optimization.maxIteration,...
                'NumSeedPoints', svdd.optimization.points, ...
                 'PlotFcn', plotFcn,...
                 'OutputFcn', outputFunc);
            % optimization results
            [svdd.optimization.bestParam, ~, ~] = bestPoint(results, 'Criterion', 'min-observed');
        end
        
        function gaopt(svdd, objFunc)
            %{
                Optimize the parameters using Genetic Algorithm (GA)
                For detailed introduction of the algorithm and parameter
                setting, please enter 'help ga' in the command line.
            %}
            seedSize = 10*svdd.optimization.numVariables;
            switch svdd.optimization.display
                case 'on'
                    display_ = 'iter';
                    outputFunc = @SvddOptimization.outputFunc;
                case 'off'
                    display_ = 'off';
                    outputFunc = {[]};
            end
            options = optimoptions('ga', 'PopulationSize', seedSize,...
                'MaxGenerations', svdd.optimization.maxIteration,...
                'Display', display_, 'PlotFcn', [], 'OutputFcn', outputFunc);
            bestParam_ = ga(objFunc, svdd.optimization.numVariables, [], [], [], [],...
                svdd.optimization.lowerBound, svdd.optimization.upperBound, [], [], options);

            % optimization results
            svdd.optimization.bestParam.Variables = bestParam_;
        end

        function psoopt(svdd, objFunc)
            %{
                Optimize the parameters using Particle Swarm Optimization (PSO)
                For detailed introduction of the algorithm and parameter
                setting, please enter 'help particleswarm' in the command line.
            %}

            seedSize = 10*svdd.optimization.numVariables;
            % setting of display
            switch svdd.optimization.display
                case 'on'
                    outputFunc = @SvddOptimization.outputFunc;
                    display_ = 'iter';
                case 'off'
                    outputFunc = [];
                    display_ = 'off';
            end

            options = optimoptions('particleswarm', 'SwarmSize', seedSize,...
                'MaxIterations', svdd.optimization.maxIteration,...
                'Display', display_, 'OutputFcn', outputFunc, 'PlotFcn', []);
            bestParam_ = particleswarm(objFunc, svdd.optimization.numVariables,...
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

        function varargout = outputFunc(varargin)
            persistent IterationFIGURE
            stop = false;
            optimization_ = evalin('base', 'optimization_');
            svdd_ = evalin('base', 'svdd');
            switch svdd_.optimization.method
                case 'bayes'
                    state = varargin{1, 2};
                    varargout{1, 1} = stop;
                    if ~isempty(varargin{1, 1}.ObjectiveMinimumTrace)
                        currentIteration = length(varargin{1, 1}.ObjectiveMinimumTrace);
                        currentObjFuncValue = varargin{1, 1}.ObjectiveMinimumTrace(currentIteration, 1);
                    end

                case 'ga'
                    state = varargin{1, 3};
                    varargout{1, 1} = varargin{1, 2};
                    varargout{1, 2} = varargin{1, 1};
                    varargout{1, 3} = stop;
                    if strcmp(state, 'init')
                        state = 'initial';
                    end
                    if strcmp(state, 'iter')
                        state = 'iteration';
                    end
                    currentIteration = varargin{1, 2}.Generation;
                    if ~isempty(varargin{1, 2}.Best)
                        currentObjFuncValue = varargin{1, 2}.Best(1, currentIteration);
                    end

                case 'pso'
                    state = varargin{1, 2};
                    varargout{1, 1} = stop;
                    if strcmp(state, 'init')
                        state = 'initial';
                    end
                    if strcmp(state, 'iter')
                        state = 'iteration';
                    end
                    currentIteration = varargin{1, 1}.iteration;
                    currentObjFuncValue = varargin{1, 1}.bestfval;
            end

            switch state
                case 'initial'
                    IterationFIGURE = figure;
                    optimization_.line = animatedline( ...
                        'Color', [0.85 0.325 0.098], ...
                        'LineWidth',0.6, 'LineStyle', '-', ...
                        'Marker','o', 'MarkerSize', 5,...
                        'MarkerEdgeColor',[0.85 0.325 0.098], ...
                        'MarkerFaceColor', [0.85 0.325 0.098]);
                    xlabel('Iterations')
                    ylabel('Objective function values')
                    grid on
                    drawnow

                case 'iteration'
                    figure(IterationFIGURE)
                    elapsedTime = toc(optimization_.startTime);
                    D = duration(0, 0, elapsedTime, 'Format', 'hh:mm:ss');
                    addpoints(optimization_.line, currentIteration, currentObjFuncValue)
                    title(['Iteration: ', num2str(currentIteration), ', Elapsed: ', cell2mat(string(D))])
                    optimization_.objFuncValues(currentIteration, 1) = currentObjFuncValue;
                    optimization_.totalElapsedTime(currentIteration, 1) = elapsedTime;

                case 'done'
                    % No cleanup necessary
            end
            assignin('base','optimization_', optimization_)
        end

        function checkParameter(svdd)
            optimization_ = svdd.optimization;
            if ~strcmp(svdd.kernelType, 'single')
                error('Parameter optimization is not supported for hybrid kernel SVDD in the current version.')      
            end
            % parameter initialization
            svdd.optimization.method = 'bayes';
            switch svdd.kernelFunc.type
                case {'gaussian', 'laplacian'}
                    svdd.optimization.variableName = {'gamma'};
                    svdd.optimization.variableType = {'real'};
                    svdd.optimization.lowerBound = 2^(-9);
                    svdd.optimization.upperBound = 2^9;
                case 'polynomial'
                    svdd.optimization.variableName =  {'gamma', 'offset', 'degree'};
                    svdd.optimization.variableType = {'real', 'real', 'integer'};
                    svdd.optimization.lowerBound = [2^(-9), 1e-3, 1];
                    svdd.optimization.upperBound = [2^9, 1e3, 7];
                case 'sigmoid'
                    svdd.optimization.variableName =  {'gamma', 'offset'};
                    svdd.optimization.variableType = {'real', 'real'};
                    svdd.optimization.lowerBound = [2^(-9), 1e-3];
                    svdd.optimization.upperBound = [2^9, 1e3];
            end
            svdd.optimization.variableName{1, end+1} = 'cost';
            svdd.optimization.variableType{1, end+1} = 'real';
            svdd.optimization.lowerBound(1, end+1) = 1/svdd.numSamples+eps;
            svdd.optimization.upperBound(1, end+1) = 1;  

            % others
            svdd.optimization.maxIteration = 100;
            svdd.optimization.display = 'on';
            svdd.optimization.points = 5;

            % custom input
            name_ = fieldnames(optimization_);
            for i = 1:size(name_, 1)
                svdd.optimization.(name_{i, 1}) = optimization_.(name_{i, 1});
            end
            svdd.optimization.numVariables = length(svdd.optimization.variableName);
            % methods
            supportedMethod = {'bayes', 'pso', 'ga'};
            supportedVariableName = {'cost', 'degree', 'offset', 'gamma'};
            supportedVariableType = {'real', 'integer', 'real', 'real'};

            % check methods
            if ~any(strcmp(svdd.optimization.method, supportedMethod))
                str_1 = 'The optimization methods are only supported for ';
                str_2 = '''bayes'', ''pso'', and ''ga''.';
                error([str_1, str_2])
            end

            % check variables
            if ~isempty(setdiff(svdd.optimization.variableName, supportedVariableName))
                str_1 = 'The variabel optimization are only supported for ';
                str_2 = '''cost'', ''degree'', ''offset'', and ''gamma''.';
                error([str_1, str_2])
            end

            % check variable type
            variabelTypeMap = containers.Map(supportedVariableName, supportedVariableType);
            for i = 1:svdd.optimization.numVariables
                name_ = svdd.optimization.variableName{i};
                type_ = svdd.optimization.variableType{i};
                if ~strcmp(variabelTypeMap(name_), type_)
                    errorText = strcat(...
                        'The variabel types should be set as follows:\n',...
                        '--------------------------------------------\n',...
                        '''cost'' --> ''real''\n',...
                        '''degree'' --> ''integer''\n',...
                        '''offset'' --> ''real''\n',...
                        '''gamma'' --> ''real''\n');
                    error(sprintf(errorText))
                end
            end
        end
    end
end
