% Continuous Ant Colony Optimization (ACOR)
classdef ypea_acor < ypea_algorithm
    
    properties
        
        % Number of Newly Generated Samples
        sample_count = 50;
        
        % Intensification Factor (Selection Pressure)
        q = 0.5;
        
        % Deviation-Distance Ratio
        zeta = 1;
        
    end
    
    methods
        
        % Constructor
        function this = ypea_acor()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Continuous Ant Colony Optimization';
            this.short_name = 'ACOR';
            
        end
        
        % Setter for Sample Count
        function set.sample_count(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'nonnegative'});
            this.sample_count = value;
        end
        
        % Setter for Intensification Factor (q)
        function set.q(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.q = value;
        end
        
        % Setter for Deviation-Distance Ratio (zeta)
        function set.zeta(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.zeta = value;
        end
        
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)

            % Create Initial Population (Sorted)
            sorted = true;
            this.init_pop(sorted);
            
            % Calculate Selection Probabilities
            qn = this.q * this.pop_size;
            w = 1/(sqrt(2*pi)*qn)*exp(-0.5*(((1:this.pop_size)-1)/qn).^2);
            this.params.p = ypea_normalize_probs(w);
            
        end
        
        % Iterations
        function iterate(this)
            
            % Decision Vector Size
            var_size = this.problem.var_size;
            
            % Means and Standard Deviations
            s = this.get_positions(this.pop);
            sigma = zeros(size(s));
            for l = 1:this.pop_size
                D = sum(abs(repmat(s(l,:), this.pop_size, 1) - s));
                sigma(l,:) = this.zeta*D/(this.pop_size - 1);
            end
            
            % Generate Samples
            new_pop = repmat(this.empty_individual, this.sample_count, 1);
            for k = 1:this.sample_count
                x = zeros(var_size);
                for i = 1:numel(x)
                    l = ypea_roulette_wheel_selection(this.params.p);
                    x(i) = s(l,i) + sigma(l,i)*randn();
                end
                new_pop(k) = this.new_individual(x);
            end
            
            % Merge, Sort and Selection
            this.pop = this.sort_and_select([this.pop; new_pop]);
            
            % Determine Best Solution
            this.best_sol = this.pop(1);
            
        end
    end
    
end