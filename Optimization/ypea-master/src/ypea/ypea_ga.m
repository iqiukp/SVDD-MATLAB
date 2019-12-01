% Genetic Algorithm (GA)
classdef ypea_ga < ypea_algorithm
    
    properties
        
        % Crossover Probability
        crossover_prob = 0.7;
        
        % Crossover Inflation (Extrapolation Factor)
        crossover_inflation = 0.1;
        
        % Mutation Probability
        mutation_prob = 0.3;
        
        % Mutation Rate
        mutation_rate = 0.1;
        
        % Mutation Step Size
        mutation_step_size = 0.1;
        
        % Mutation Step Size Damp Rate
        mutation_step_size_damp = 0.99;
        
        % Selection Method (random or roulettewheel)
        selection = 'roulettewheel';
        
        % Selection Pressure (user with Roulette Wheel Selection)
        selection_pressure = 5;
        
    end
    
    methods
        
        % Constructor
        function this = ypea_ga()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Genetic Algorithm';
            this.short_name = 'GA';
            
        end
        
        % Setter for Crossover Probability
        function set.crossover_prob(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.crossover_prob = value;
        end
        
        % Setter for Mutation Probability
        function set.mutation_prob(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.mutation_prob = value;
        end
        
        % Setter for Crossover Inflation Factor
        function set.crossover_inflation(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative', '<=', 1});
            this.crossover_inflation = value;
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
        
        % Setter for Mutation Step Size Damp Rate
        function set.mutation_step_size_damp(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.mutation_step_size_damp = value;
        end
        
        % Setter for Selection Method
        function set.selection(this, value)
            validateattributes(value, {'char', 'string'}, {});
            switch lower(value)
                case {'rand', 'random'}
                    value = 'random';
                    
                case {'rw', 'rws', 'roulette', 'roulettewheel'}
                    value = 'roulettewheel';
                    
                otherwise
                    error('Invalid selection method. Must be ''random'' or ''roulettewheel''.');
            end
            this.selection = value;
        end
        
        % Setter for Selection Pressure
        function set.selection_pressure(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.selection_pressure = value;
        end
        
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)
            
            % Create Initial Population (Sorted)
            sorted = true;
            this.init_pop(sorted);
            
            % Initial Value of Mutation Step Size
            this.params.sigma = this.mutation_step_size;
            
        end
        
        % Iterations
        function iterate(this)
            
            % Population Size
            pop_size = this.pop_size;
            
            
            % Calculate Selection Probabilities
            rws = strcmpi(this.selection, 'roulettewheel');
            if rws
                beta = this.selection_pressure;
                obj_values = this.get_objective_values(this.pop);
                P = this.get_selection_probs(obj_values, beta);
            end
            
            % Perform Crossover
            nc = 2*round(this.crossover_prob * pop_size/2);
            popc = repmat(this.empty_individual, nc/2, 2);
            for k = 1:nc/2
                
                % Select Parents
                if rws
                    i1 = ypea_roulette_wheel_selection(P);
                    i2 = ypea_roulette_wheel_selection(P);
                else
                    i1 = randi([1 pop_size]);
                    i2 = randi([1 pop_size]);
                end
                
                % Perform Crossover
                x1 = this.pop(i1).position;
                x2 = this.pop(i2).position;
                [y1, y2]=this.crossover(x1, x2);
                
                % Evaluate Offsprings
                popc(k,1) = this.new_individual(y1);
                popc(k,2) = this.new_individual(y2);
                
            end
            popc = popc(:);
            
            % Perform Mutation
            nm = round(this.mutation_prob * pop_size);
            popm = repmat(this.empty_individual, nm, 1);
            for k = 1:nm
                
                % Select Parent
                i = randi([1 pop_size]);
                x = this.pop(i).position;
                
                % Perform Mutation
                y = this.mutate(x);
                
                % Evaluate Offspring
                popm(k) = this.new_individual(y);
                
            end
            
            % Merge, Sort and Selection
            this.pop = this.sort_and_select([this.pop; popm; popc]);
            
            % Update Best Solution Ever Found
            this.best_sol = this.pop(1);
            
            % Damp Mutation Step Size
            this.params.sigma = this.mutation_step_size_damp * this.params.sigma;          
            
        end
        
        % Perform Crossover
        function [y1, y2] = crossover(this, x1, x2)
            
            gamma = this.crossover_inflation;
            alpha = ypea_uniform_rand(-gamma, 1+gamma, size(x1));
            
            y1 = alpha.*x1 + (1-alpha).*x2;
            y2 = alpha.*x2 + (1-alpha).*x1;
            
            y1 = ypea_clip(y1, 0, 1);
            y2 = ypea_clip(y2, 0, 1);
            
        end
        
        % Perform Mutation
        function y = mutate(this, x)
            
            mu = this.mutation_rate;
            sigma = this.params.sigma;
            
            nvar = numel(x);
            nmu = ceil(mu * nvar);
            
            j = ypea_rand_sample(nvar, nmu);
            
            y = x;
            y(j) = x(j) + sigma*randn(size(j));
            
            y = ypea_clip(y, 0, 1);
            
        end
        
    end
    
end