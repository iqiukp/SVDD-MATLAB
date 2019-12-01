% Invasive Weed Optimization (IWO)
classdef ypea_iwo < ypea_algorithm
    
    properties
        
        % Initial Population Size
        initial_pop_size = 10;
        
        % Minimum Seed Count
        min_seed_count = 0;
        
        % Maximum Seed Count
        max_seed_count = 5;
        
        % Step size
        step_size = 0.1;
        
        % Step Size Damp Rate
        step_size_damp = 0.001;
        
    end
    
    properties(Dependent = true)
        
        % Maximum Population Size (alias of pop_size)
        max_pop_size;
        
    end
    
    methods
        
        % Constructor
        function this = ypea_iwo()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Invasive Weed Optimization';
            this.short_name = 'IWO';
            
            this.max_pop_size = 20;
        end
        
        % Getter for Maximum Population Size (alias of pop_size)
        function value = get.max_pop_size(this)
            value = this.pop_size;
        end
        
        % Setter for Maximum Population Size (alias of pop_size)
        function set.max_pop_size(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'positive'});
            this.pop_size = value;
        end
        
        % Setter for Minimum Number of Seeds
        function set.min_seed_count(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'nonnegative'});
            this.min_seed_count = value;
        end
        
        % Setter for Maximum Number of Seeds
        function set.max_seed_count(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'nonnegative'});
            this.max_seed_count = value;
        end
        
        % Setter for Step Size
        function set.step_size(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.step_size = value;
        end
        
        % Setter for Step Size Damp Rate
        function set.step_size_damp(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.step_size_damp = value;
        end
        
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)
            
            % Create Initial Population (Not Sorted)
            sorted = false;
            this.init_pop(sorted);
            
            % Initial Value of Step Size
            this.params.sigma = this.step_size;
            
        end
        
        % Iterations
        function iterate(this)
            
            % Minimum and Maximum Number of Seeds
            Smin = this.min_seed_count;
            Smax = this.max_seed_count;
            
            % Decision Vector Size
            var_size = this.problem.var_size;
            
            % Get Best and Worst Cost Values
            obj_values = [this.pop.obj_value];
            best_obj_value = this.problem.find_best(obj_values);
            worst_obj_value = this.problem.find_worst(obj_values);
            
            % Initialize Offsprings Population
            newpop = repmat(this.empty_individual, numel(this.pop)*Smax, 1);
            c = 0;
            
            % Reproduction
            for i = 1:numel(this.pop)

                ratio = (this.pop(i).obj_value - worst_obj_value)/(best_obj_value - worst_obj_value);
                S = floor(Smin + (Smax - Smin)*ratio);

                for j = 1:S

                    % Generate Random Location
                    xnew = this.pop(i).position + this.params.sigma * randn(var_size);
                    newsol = this.new_individual(xnew);
                    
                    % Add Offpsring to the Population
                    c = c +1;
                    newpop(c) = newsol;
                    
                end

            end
            newpop = newpop(1:c);
            
            % Merge and Sort Populations
            this.pop = this.sort_and_select([this.pop; newpop]);

            % Update Best Solution Ever Found
            this.best_sol = this.pop(1);
            
            % Damp Step Size
            this.params.sigma = this.step_size_damp * this.params.sigma;
            
        end
    end
    
end