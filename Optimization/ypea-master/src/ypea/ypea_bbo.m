% Biogeography-based Optimization (BBO)
classdef ypea_bbo < ypea_algorithm
    
    properties
        
        % Keep Rate
        keep_rate = 0.2;
        
        % Acceleration Coefficient
        alpha = 0.9;
        
        % Mutation Probability
        mutation_prob = 0.1;
        
        % Mutation Step Size
        mutation_step_size = 0.05;
        
        % Mutation Step Size Damp Rate
        mutation_step_size_damp = 0.99;
        
    end
    
    methods
        
        % Constructor
        function this = ypea_bbo()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Biogeography-based Optimization';
            this.short_name = 'BBO';
            
        end
        
        % Setter for Keep Rate
        function set.keep_rate(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.keep_rate = value;
        end
        
        % Setter for Acceleration Coefficient (alpha)
        function set.alpha(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.alpha = value;
        end
        
        % Setter for Mutation Probability
        function set.mutation_prob(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.mutation_prob = value;
        end
        
        % Setter for Mutation Step Size
        function set.mutation_step_size(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.mutation_step_size = value;
        end
        
        % Setter for Mutation Step Size Damp Rate
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
            
            % Set Keep Count
            this.params.keep_count = round(this.keep_rate * this.pop_size);
            
            % Set Newly Created Solutions Count
            this.params.new_count = this.pop_size - this.params.keep_count;
            
            % Emmigration Rates
            this.params.mu = linspace(1, 0, this.pop_size);
            
            % Immigration Rates
            this.params.lambda = 1 - this.params.mu;
            
            % Initial Value of Mutation Step Size
            this.params.sigma = this.mutation_step_size;
            
        end
        
        % Iterations
        function iterate(this)
            
            % Decision Vector Size
            var_count = this.problem.var_count;
            
            % Create New Population
            newpop = this.pop;
            for i = 1:this.pop_size
                
                % Generate New Solution
                xnew = newpop(i).position;
                for k = 1:var_count
                    
                    % Migration
                    if rand <= this.params.lambda(i)
                        
                        % Emmigration Probabilities
                        EP = this.params.mu;
                        EP(i) = 0;
                        EP = EP/sum(EP);
                        
                        % Select Source Habitat
                        j = ypea_roulette_wheel_selection(EP);
                        
                        % Migration
                        xnew(k) = this.pop(i).position(k) ...
                            + this.alpha*(this.pop(j).position(k) - this.pop(i).position(k));
                        
                    end

                    % Mutation
                    if rand <= this.mutation_prob
                        xnew(k) = xnew(k) + this.params.sigma*randn;
                    end
                    
                end
                
                % Create New Solution
                newpop(i) = this.new_individual(xnew);
                
            end
            
            % Sort, Select and Merge
            keep_count = this.params.keep_count;
            new_count = this.params.new_count;
            newpop = this.sort_population(newpop);
            this.pop = this.sort_and_select([this.pop(1:keep_count); newpop(1:new_count)]);
            
            % Update Best Solution Ever Found
            this.best_sol = this.pop(1);
            
            % Damp Mutation Step Size
            this.params.sigma = this.mutation_step_size_damp * this.params.sigma;
                        
        end
    end
    
end