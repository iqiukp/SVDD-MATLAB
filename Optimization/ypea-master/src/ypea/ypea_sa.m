% Simulated Annealing (SA)
classdef ypea_sa < ypea_algorithm
    
    properties
        
        % Maximum Number of Sub-Iteration (within fixed temperature)
        max_sub_iter = 10;
        
        % Initial Temperature
        initial_temp = 1000;
        
        % Final Temperature
        final_temp = 1;
        
        % Move Count per Individual Solution
        move_count = 5;
        
        % Mutation Rate
        mutation_rate = 0.1;
        
        % Mutation Step Size
        mutation_step_size = 0.1;
        
        % Mutation Step Size Damp
        mutation_step_size_damp = 0.99;
        
    end
    
    methods
        
        % Constructor
        function this = ypea_sa()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Simulated Annealing';
            this.short_name = 'SA';
            
            % Initialize Population Size
            this.pop_size = 10;
            
        end
        
        % Setter for Maximum Number of Sub-Iterations
        function set.max_sub_iter(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', 'integer'});
            this.max_sub_iter = value;
        end
        
        % Setter for Initial Temperature
        function set.initial_temp(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.initial_temp = value;
        end
        
        % Setter for Final Temperature
        function set.final_temp(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.final_temp = value;
        end
        
        % Setter for Move Count per Individual Solution
        function set.move_count(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', 'integer'});
            this.move_count = value;
        end
        
        % Setter for Mutation Rate
        function set.mutation_rate(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative', '<=', 1});
            this.mutation_rate = value;
        end
        
        % Setter for Mutation Step Size
        function set.mutation_step_size(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.mutation_step_size = value;
        end
        
        % Setter for utation Step Size Damp
        function set.mutation_step_size_damp(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.mutation_step_size_damp = value;
        end
        
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)
            
            % Create Initial Population (Sorted)
            sorted = true;
            this.init_pop(sorted);
            
            % Initial Temperature
            this.params.temp = this.initial_temp;
            
            % Calculate Temperature Damp Rate
            this.params.temp_damp = (this.final_temp/this.initial_temp)^(1/this.max_iter);

            % Initial Value of Step Size
            this.params.sigma = this.mutation_step_size;
            
        end
        
        % Iterations
        function iterate(this)
            
            % Sub-Iterations
            for sub_iter = 1:this.max_sub_iter
                
                % Create New Population
                newpop = repmat(this.empty_individual, this.pop_size, this.move_count);
                for i = 1:this.pop_size
                    for j = 1:this.move_count
                        
                        % Perform Mutation (Move)
                        x = this.mutate(this.pop(i).position);
                        
                        % Evaluation
                        newpop(i,j) = this.new_individual(x);
                        
                    end
                end
                
                % Columnize and Sort Newly Created Population
                newpop = this.sort_population(newpop(:));
                
                % Compare the Best New Individual to Best Solution
                if this.is_better(newpop(1), this.best_sol)
                    this.best_sol = newpop(1);
                end
                
                % Randomized Selection
                for i = 1:this.pop_size
                    
                    % Check if new solution is better than current
                    if this.is_better(newpop(i), this.pop(i))
                        
                        % If better, replace the old one
                        this.pop(i) = newpop(i);
                        
                    else
                        
                        % Compute difference according to problem type
                        if this.problem.is_maximization()
                            delta = this.pop(i).obj_value - newpop(i).obj_value;
                        else
                            delta = newpop(i).obj_value - this.pop(i).obj_value;
                        end
                        
                        % Compute Acceptance Probability
                        p = exp(-delta/this.params.temp);
                        
                        % Accept / Reject
                        if rand() <= p
                            this.pop(i) = newpop(i);
                        end
                        
                    end
                end
                
            end
            
            % Update Temperature
            this.params.temp = this.params.temp_damp * this.params.temp;
            
            % Damp Step Size
            this.params.sigma = this.mutation_step_size_damp * this.params.sigma;
            
        end
        
        % Perform Mutation (Create Neighbor Solution)
        function y = mutate(this, x)
            
            % Mutation Rate
            mu = this.mutation_rate;
            
            % Select Mutating Variables
            flag = (rand(size(x)) <= mu);
            if ~any(flag)
                % Select at least one variable to mutate
                j0 = randi(numel(x));
                flag(j0) = true;
            end
            j = find(flag);
            
            % Create Mutated Vector
            y = x;
            y(j) = x(j) + this.params.sigma*randn(size(j));
            
            % Clip the Output
            y = ypea_clip(y, 0, 1);
            
        end
        
    end
    
end