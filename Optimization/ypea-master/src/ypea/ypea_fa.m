% Firefly Algorithm (FA)
classdef ypea_fa < ypea_algorithm
    
    properties
        
        % Light Absorption Coefficient
        gamma = 1;
        
        % Attraction Coefficient Base Value
        beta_base = 2;
        
        % Mutation Coefficient
        alpha = 0.2;
        
        % Mutation Coefficient Damp Rate
        alpha_damp = 0.99;
        
        % Mutation Step Size
        delta = 0.05;
        
        % Exponent
        m = 2;
        
    end
    
    methods
        
        % Constructor
        function this = ypea_fa()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Firefly Algorithm';
            this.short_name = 'FA';
            
        end
        
        % Setter for Light Absorption Coefficient (gamma)
        function set.gamma(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.gamma = value;
        end
        
        % Setter for Attraction Coefficient Base Value (beta_base)
        function set.beta_base(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.beta_base = value;
        end
        
        % Setter for Mutation Coefficient
        function set.alpha(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.alpha = value;
        end
        
        % Setter for Mutation Coefficient Damp Rate
        function set.alpha_damp(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.alpha_damp = value;
        end
        
        % Setter for Mutation Step Size (delta)
        function set.delta(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.delta = value;
        end
        
        % Setter for Exponent Parameter (m)
        function set.m(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.m = value;
        end
        
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)
            
            % Create Initial Population (Not Sorted)
            sorted = false;
            this.init_pop(sorted);
            
            % Initial Value of Mutation Coefficient
            this.params.alpha = this.alpha;
            
        end
        
        % Iterations
        function iterate(this)
            
            % Maximum Distance
            dmax = sqrt(this.problem.var_count);
            
            % Decision Vector Size
            var_size = this.problem.var_size;
            
            % Create New Population
            newpop = repmat(this.empty_individual, this.pop_size, 1);
            for i = 1:this.pop_size
                
                % Initialize to Worst Objective Value
                newpop(i).obj_value = this.problem.worst_value;
                for j = 1:this.pop_size
                    
                    % Move Towards Better Solutions
                    if this.is_better(this.pop(j), this.pop(i))
                        
                        % Calculate Radius and Attraction Level
                        rij = norm(this.pop(i).position - this.pop(j).position)/dmax;
                        beta = this.beta_base*exp(-this.gamma * rij^this.m);
                        
                        % Mutation Vector
                        e = this.delta*ypea_uniform_rand(-1, 1, var_size);
                        
                        % New Solution
                        xnew = this.pop(i).position ...
                             + beta*rand(var_size).*(this.pop(j).position - this.pop(i).position) ...
                             + this.params.alpha*e;
                        
                         % Evaluate New Solution
                        newsol = this.new_individual(xnew);
                        
                        % Comare to Previous Solution
                        if this.is_better(newsol, newpop(i))
                            
                            % Replace Previous Solution
                            newpop(i) = newsol;
                            
                            % Compare to Best Solution Ever Found
                            if this.is_better(newsol, this.best_sol)
                                this.best_sol = newpop(i);
                            end
                            
                        end

                    end
                    
                end
                
            end

            % Merge, Sort and Select
            this.pop = this.sort_and_select([this.pop; newpop]);
            
            % Update Best Solution Ever Found
            this.best_sol = this.pop(1);
            
            % Damp Mutation Coefficient
            this.params.alpha = this.alpha_damp * this.params.alpha;
                        
        end
    end
    
end