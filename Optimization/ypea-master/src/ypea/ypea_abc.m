% Artificial Bee Colony (ABC)
classdef ypea_abc < ypea_algorithm
    
    properties
        
        % Onlooker Bees Count
        onlooker_count = 100;
        
        % Max. Acceleration Coefficient
        max_acceleration = 1;
        
    end
    
    methods
        
        % Constructor
        function this = ypea_abc()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Artificial Bee Colony';
            this.short_name = 'ABC';
            
        end
        
        % Setter for Onlooker Bees Count
        function set.onlooker_count(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', 'integer'});
            this.onlooker_count = value;
        end
        
        % Setter for Max. Acceleration Coefficient
        function set.max_acceleration(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.max_acceleration = value;
        end
        
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)
            
            % Create Initial Population (Not Sorted)
            sorted = false;
            this.init_pop(sorted);
            
            % Abandonment Limit Parameter (Trial Limit)
            this.params.L = round(0.6 * this.problem.var_count * this.pop_size);
            
            % Abandonment Counter
            this.params.C = zeros(this.pop_size, 1);
            
        end
        
        % Iterations
        function iterate(this)
            
            % Decision Vector Size
            var_size = this.problem.var_size;
            
            % Recruited Bees
            for i = 1:this.pop_size
                
                % Choose k randomly, not equal to i
                K = [1:i-1 i+1:this.pop_size];
                k = K(randi([1 numel(K)]));
                
                % Define Acceleration Coeff.
                phi = this.max_acceleration*ypea_uniform_rand(-1 , 1, var_size);

                % New Bee Position
                xnew = this.pop(i).position ...
                     + phi.*(this.pop(i).position - this.pop(k).position);
                newsol = this.new_individual(xnew);
                
                % Comparision
                if this.is_better(newsol, this.pop(i))
                    this.pop(i) = newsol;
                else
                    this.params.C(i) = this.params.C(i)+1;
                end

            end

            % Calculate Fitness Values and Selection Probabilities
            obj_values = this.get_objective_values(this.pop);
            P = this.get_selection_probs(obj_values);
            
            % Onlooker Bees
            for m = 1:this.onlooker_count

                % Select Source Site
                i = ypea_roulette_wheel_selection(P);
                
                % Choose k randomly, not equal to i
                K = [1:i-1 i+1:this.pop_size];
                k = K(randi([1 numel(K)]));
                
                % Define Acceleration Coeff.
                phi = this.max_acceleration*ypea_uniform_rand(-1 , 1, var_size);

                % New Bee Position
                xnew = this.pop(i).position ...
                     + phi.*(this.pop(i).position - this.pop(k).position);
                newsol = this.new_individual(xnew);
                
                % Comparision
                if this.is_better(newsol, this.pop(i))
                    this.pop(i) = newsol;
                else
                    this.params.C(i) = this.params.C(i)+1;
                end
                
            end

            % Scout Bees
            for i = 1:this.pop_size
                if this.params.C(i) >= this.params.L
                    this.pop(i) = this.new_individual();
                    this.params.C(i) = 0;
                end
            end
            
            % Update Best Solution Ever Found
            for i = 1:this.pop_size
                if this.is_better(this.pop(i), this.best_sol)
                    this.best_sol = this.pop(i);
                end
            end
            
        end
        
    end
    
end