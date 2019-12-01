% Abstract Evolutionary Algorithm (Abs. EA)
classdef (Abstract) ypea_algorithm < handle
    
    properties
        
        % Full Name of the Evolutionary Algorithm
        name = 'Abstract Evolutionary Algorithm';
        
        % Short Name of the Evolutionary Algorithm
        short_name = 'Abs. EA';
        
        % Maximum Number of Iterations
        max_iter = 100;
        
        % Population Size
        pop_size = 100;
        
        % Display Iteration Info
        display = true;
        
    end
    
    properties(SetAccess = protected)
        
        % Structure to hold specific parameters of the algorithm
        params;
        
        % Structure for Empty Individual
        empty_individual = [];
        
        % The Optimization Problem being solved by the algorithm
        problem = [];
        
        % Default Problem
        default_problem = [];
        
        % Population Array
        pop = [];
        
        % Best Solution Ever Found
        best_sol = [];
        
        % Iteration Counter
        iter = 0;
        
        % Number fo Function Evaluations
        nfe = 0;
        
        % Run Time
        run_time = 0;
        
        % Average Function Evaluation Time
        avg_eval_time = 0;
        
        % History of NFEs
        nfe_history = [];
        
        % History of Best Objective Values
        best_obj_value_history = [];
        
        % The Force Stop Flag
        must_stop = false;
        
    end
    
    properties(Dependent = true)
        
        % Full Name
        full_name = [];

        % Best Objective Value Ever Found
        best_obj_value = [];
        
        % Effective Problem
        eff_problem = [];
        
    end
    
    methods
        
        % Constructor
        function this = ypea_algorithm()
            
            % Initialize Empty Individual Structure
            this.empty_individual.position = [];
            this.empty_individual.obj_value = [];
            this.empty_individual.solution = [];
            
            % Initialize Default Problem
            this.default_problem = ypea_problem();
            
        end
        
        % Getter for Full Name
        function value = get.full_name(this)
            value = [this.name ' (' this.short_name ')'];
        end
        
        % Setter for Maximum Number of Iterations
        function set.max_iter(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', 'integer'});
            this.max_iter = max(floor(value), 1);
        end
        
        % Setter for Population Size
        function set.pop_size(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', 'integer'});
            this.pop_size = max(floor(value), 1);
        end
        
        % Setter for Display Flag
        function set.display(this, value)
            validateattributes(value, {'logical'}, {});
            this.display = logical(value);
        end
        
        % Getter for Best Objective Value Ever Found
        function value = get.best_obj_value(this)
            value = this.best_sol.obj_value;
        end
        
        % Getter for Effective Problem
        function value = get.eff_problem(this)
            if isa(this.problem, 'ypea_problem')
                value = this.problem;
            else
                value = this.default_problem;
            end
        end
        
        % Solves a Optimization Problem
        function the_best_sol = solve(this, problem)
            
            % Check for Valid Optimization Problem Type
            validateattributes(problem, {'ypea_problem'}, {});
            this.problem = problem;
            
            % Reset the Algorithm Status
            this.reset();
            
            % Start Timer
            tic();
            
            % Execution Started
            if this.display
                disp([this.name ' started ...']);
            end
            this.notify('started');
            
            % Initialization
            if this.display
                disp('Initializing population.');
            end
            this.initialize();
            
            % Check for Goals and Termination Conditions
            this.check_for_goals();
            
            % If goals not meeted, then run
            if ~this.must_stop
                
                % Iterations (Main Loop)
                for it = 1:this.max_iter
                    
                    % Set Iteration Counter
                    this.iter = it;
                    
                    % Iteration Started
                    this.notify('iteration_started');
                    this.iterate();
                    
                    % Update Histories
                    this.nfe_history(it) = this.nfe;
                    this.best_obj_value_history(it) = this.best_obj_value;
                    
                    % Iteration Ended
                    this.notify('iteration_ended');
                    
                    % Display Iteration Information
                    if this.display
                        disp(['Iteration ' num2str(this.iter) ...
                              ': Best this. Value = ' num2str(this.best_obj_value) ...
                              ', NFE = ' num2str(this.nfe)]);
                    end
                    
                    % Check for Goals and Termination Conditions
                    this.check_for_goals();
                    
                    % Check if it is needed to stop the execution
                    if this.must_stop
                        break;
                    end
                    
                end
                
                % If stopped before reaching the final iteration
                if it < this.max_iter
                    this.nfe_history = this.nfe_history(1:it);
                    this.best_obj_value_history = this.best_obj_value_history(1:it);
                end
                
            end
            
            % End of Execution
            if this.display
                disp('End of optimization.');
            end
            this.notify('ended');
            
            % Calculated Time Elapsed
            this.run_time = toc();
            
            % Calculate Average Function Evaluation Time
            this.avg_eval_time = this.run_time / this.nfe;
            
            % Set the output, if it is needed to
            if nargout > 0
                the_best_sol = this.best_sol;
            end
            
        end
        
        % Stopping the Algorithm Execution
        function stop(this)
            this.must_stop = true;
        end
        
        % Check for Goals and Termination Conditions
        function check_for_goals(this)
            
            % Check if Goal Objetive Value satisfied
            if ~isempty(this.problem.goal) && this.is_better(this.best_sol, this.problem.goal)
                this.stop();
            end
            
            % Check if Maximum NFE is reached
            if ~isempty(this.problem.max_nfe) && this.nfe >= this.problem.max_nfe
                this.stop();
            end
            
        end
        
        % Add Start Event Listener
        function on_start(this, event_handler)
            this.addlistener('started', event_handler);
        end
        
        % Add End Event Listener
        function on_end(this, event_handler)
            this.addlistener('ended', event_handler);
        end
        
        % Add Iteration Start Event Listener
        function on_iteration_start(this, event_handler)
            this.addlistener('iteration_started', event_handler);
        end
        
        % Add Iteration End Event Listener
        function on_iteration_end(this, event_handler)
            this.addlistener('iteration_ended', event_handler);
        end
        
        % Plot of the Objective Value History vs. Iterations/NFEs
        function h = plot(this, mode, varargin)
            
            % Check if mode is set
            if ~exist('mode', 'var') || isempty(mode)
                mode = 'iter';
            end
            
            % Check for Mode
            switch lower(mode)
                case {'it', 'iter', 'iteration'}
                    hh = plot(this.best_obj_value_history, varargin{:});
                    
                case {'nfe', 'fe'}
                    hh = plot(this.nfe_history, this.best_obj_value_history, varargin{:});
                    
                otherwise
                    error('MODE must be ''iteration'' or ''nfe''.');
                    
            end
            
            % Set the Output
            if nargout > 0
                h = hh;
            end
            
        end
        
        % Semi-Log Plot of the Objective Value History vs. Iterations/NFEs
        function h = semilogy(this, mode, varargin)
            
            % Check if mode is set
            if ~exist('mode', 'var') || isempty(mode)
                mode = 'iter';
            end
            
            % Check for Mode
            switch lower(mode)
                case {'it', 'iter', 'iteration'}
                    hh = semilogy(this.best_obj_value_history, varargin{:});
                    
                case {'nfe', 'fe'}
                    hh = semilogy(this.nfe_history, this.best_obj_value_history, varargin{:});
                    
                otherwise
                    error('MODE must be ''iteration'' or ''nfe''.');
                    
            end
            
            % Set the Output
            if nargout > 0
                h = hh;
            end
            
        end
        
        % Alias of semilogx
        function h = plotlog(this, mode, varargin)

            % Check if mode is set
            if ~exist('mode', 'var') || isempty(mode)
                mode = 'iter';
            end
            
            % Call semilogx
            hh = this.semilogy(mode, varargin{:});
            
            if nargout > 0
                h = hh;
            end
        end
        
    end
    
    % Abstract Methods (must be implemented by non-abstract classes)
    methods(Abstract, Access = protected)
        initialize(this)
        iterate(this)
    end
    
    methods(Access = protected)
        
        % Reset the Algorithm
        function reset(this)
            this.iter = 0;
            this.nfe = 0;
            this.nfe_history = nan(1, this.max_iter);
            this.best_obj_value_history = nan(1, this.max_iter);
            this.run_time = 0;
            this.avg_eval_time = 0;
            this.must_stop = false;
        end
        
        % Decode and Evaluate a Coded Solution
        function [z, sol] = decode_and_eval(this, xhat)
            
            % Increment NFE
            this.nfe = this.nfe + 1;
            
            % Decode and Evaluate
            if isa(this.problem, 'ypea_problem')
                [z, sol] = this.problem.decode_and_eval(xhat);
            else
                z = 0;
                sol = [];
            end
        end
        
        % Evaluate a Single Solution or Population
        function pop = eval(this, pop)
            for i = 1:numel(pop)
                pop(i).position = ypea_clip(pop(i).position, 0, 1);
                [pop(i).obj_value, pop(i).solution] = this.decode_and_eval(pop(i).position);
            end
        end
        
        % Create a New Individual
        function ind = new_individual(this, x)
            
            if ~exist('x', 'var') || isempty(x)
                x = rand(this.problem.var_size);
            end
            
            ind = this.empty_individual;
            ind.position = ypea_clip(x, 0, 1);
            [ind.obj_value, ind.solution] = this.decode_and_eval(x);
        end
        
        % Initialize Population
        function init_pop(this, sorted)
            
            % Check for Sorted flag (Default is false, not sorted)
            if ~exist('sorted', 'var') || isempty(sorted)
                sorted = false;
            end
            
            % Initialize Population Array
            this.pop = repmat(this.empty_individual, this.pop_size, 1);
            
            % Initialize Best Solution to the Worst Possible Solution
            this.best_sol = this.empty_individual;
            this.best_sol.obj_value = this.problem.worst_value;
            
            % Generate New Individuals
            for i = 1:this.pop_size
                
                % Generate New Solution
                this.pop(i) = this.new_individual();
                
                % Compare to the Best Solution Ever Found
                if ~sorted && this.is_better(this.pop(i), this.best_sol)
                    this.best_sol = this.pop(i);
                end
                
            end
            
            % Sort the Population if it is needed
            if sorted
                this.pop = this.sort_population(this.pop);
                this.best_sol = this.pop(1);
            end
            
        end
        
        % Sort Population
        function [pop, sort_order, obj_values] = sort_population(this, pop)
            
            % Check for Defined Optimization Problem
            direction = this.eff_problem.sort_direction;
            
            % Sort the Objective Values Vector
            [obj_values, sort_order] = sort([pop.obj_value], direction);
            
            % Sort (Re-order) Population
            pop = pop(sort_order);
            
        end
        
        % Sort and Select the Population
        function pop = sort_and_select(this, pop)
            
            % Sort Population
            pop = this.sort_population(pop);
            
            % Set the Population Size Limit
            n = min(this.pop_size, numel(pop));
            pop = pop(1:n);
            
        end
        
        % Check if a solution is better than other
        function b = is_better(this, x1, x2)
            b = this.eff_problem.is_better(x1, x2);
        end
        
        % Get Best Memebr of Population
        function pop_best = get_population_best(this, pop)
            pop_best = pop(1);
            for i = 2:numel(pop)
                if this.is_better(pop(i), pop_best)
                    pop_best = pop(i);
                end
            end
        end
        
        % Get Positions Matrix of Population
        function pos = get_positions(this, pop)
            pos = reshape([pop.position], this.problem.var_count, [])';
        end
        
        % Get Objective Values of Population
        function v = get_objective_values(~, pop)
            v = [pop.obj_value];
        end
        
        % Calculate Selection Probabilities
        function p = get_selection_probs(this, values, selection_pressure)
            
            % Check if Selection Pressure specified
            if ~exist('selection_pressure', 'var')
                selection_pressure = 1;
            end
            
            % Change selection pressure sign, according to problem type
            if this.eff_problem.is_maximization()
                alpha = selection_pressure;
            else
                alpha = -selection_pressure;
            end
            
            % Calculate Selection Probabilities
            p = exp(alpha*values);
            p = ypea_normalize_probs(p);
            
        end
    end
    
    % Events
    events(NotifyAccess = protected)
        started;
        ended;
        iteration_started;
        iteration_ended;
    end
    
end
