% Bees Algorithm (BA)
classdef ypea_ba < ypea_algorithm
    
    properties
        
        % Type of Algorithm (Standard or Probabilistic)
        type = 'standard';
        
        % Selected Sites Ratio (wrt. Scout Bee Count or Population Size)
        % Used in Standard BA Only
        selected_site_ratio = 0.5;
        
        % Selected Sites Bee Count Ratio (wrt. Scout Bee Count)
        % Used in Standard BA Only
        selected_site_bee_ratio = 0.1;
        
        % Elite Sites Ratio (wrt. Selected Sites Count)
        % Used in Standard BA Only
        elite_site_ratio = 0.4;
        
        % Elite Sites Bee Count Ratio (wrt. Selected Sites Bee Count)
        % Used in Standard BA Only
        elite_site_bee_ratio = 2;
        
        % Recruited Bee Count Ratio (wrt. Scout Bee Count)
        % Used in Proabilistic BA Only
        recruited_bee_ratio = 0.1;
        
        % Bees Dance Radius
        dance_radius = 0.1;
        
        % Bees Dance Radius Damp Rate
        dance_radius_damp = 0.99;
        
    end
    
    properties(Dependent = true)
        
        % Alias of Population Size
        scout_bee_count;
        
        % Selected Sites Count
        % Used in Standard BA Only
        selected_site_count;
        
        % Selected Sites Bee Count
        % Used in Standard BA Only
        selected_site_bee_count;
        
        % Elite Sites Count
        % Used in Standard BA Only
        elite_site_count;
        
        % Elite Sites Bee Count
        % Used in Standard BA Only
        elite_site_bee_count;
        
        % Recruited Bee Count
        % Used in Proabilistic BA Only
        recruited_bee_count;
        
    end
    
    methods
        
        % Constructor
        function this = ypea_ba()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Bees Algorithm';
            this.short_name = 'BA';
            
        end
        
        % Setter for Type
        function set.type(this, value)
            validateattributes(value, {'char'}, {});
            switch lower(value)
                case {'std', 'standard'}
                    this.type = 'standard';
                    
                case {'prob', 'probabilistic'}
                    this.type = 'probabilistic';
                    
                otherwise
                    error('Bees Algorithm type must be standard (std) or probabilistic (prob).');
            end
        end
        
        % Check if type is Standard
        function b = is_standard(this)
            switch lower(this.type)
                case {'std', 'standard'}
                    b = true;
                    
                otherwise
                    b = false;
            end
        end
        
        % Check if type is Probabilistic
        function b = is_probabilistic(this)
            switch lower(this.type)
                case {'prob', 'probabilistic'}
                    b = true;
                    
                otherwise
                    b = false;
            end
        end
        
        % Getter for Scount Bee Count (alias for pop_size)
        function n = get.scout_bee_count(this)
            n = this.pop_size;
        end
        
        % Getter for Scout Bee Count (alias for pop_size)
        function set.scout_bee_count(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', 'integer'});
            this.pop_size = value;
        end
        
        % Setter for Selected Site Ratio
        function set.selected_site_ratio(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', '<=', 1});
            this.selected_site_ratio = value;
        end
        
        % Setter for Selected Site Bee Ratio
        function set.selected_site_bee_ratio(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', '<=', 1});
            this.selected_site_bee_ratio = value;
        end
        
        % Setter for Elite Site Ratio
        function set.elite_site_ratio(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', '<=', 1});
            this.elite_site_ratio = value;
        end
        
        % Setter for Elite Site Bee Ratio
        function set.elite_site_bee_ratio(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.elite_site_bee_ratio = value;
        end
        
        % Setter for Recruited Bee Ratio
        function set.recruited_bee_ratio(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', '<=', 1});
            this.recruited_bee_ratio = value;
        end
        
        % Setter for Selected Site Count
        function n = get.selected_site_count(this)
            n = round(this.selected_site_ratio * this.scout_bee_count);
        end
        
        % Getter for Selected Site Bee Count
        function n = get.selected_site_bee_count(this)
            n = round(this.selected_site_bee_ratio * this.scout_bee_count);
        end
        
        % Getter for Elite Site Count
        function n = get.elite_site_count(this)
            n = round(this.elite_site_ratio * this.selected_site_count);
        end
        
        % Getter for Elite Site Bee Count
        function n = get.elite_site_bee_count(this)
            n = round(this.elite_site_bee_ratio * this.selected_site_bee_count);
        end
        
        % Getter for Recruited Bee Count
        function n = get.recruited_bee_count(this)
            n = round(this.recruited_bee_ratio * this.scout_bee_count);
        end
        
        % Setter for Bee Dance Radius
        function set.dance_radius(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.dance_radius = value;
        end
        
        % Setter for Bee Dance Radius Damp Rate
        function set.dance_radius_damp(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.dance_radius_damp = value;
        end
        
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)
            
            % Create Initial Population (Sorted)
            sorted = true;
            this.init_pop(sorted);
            
            % Initial Value of Dance Radius
            this.params.r = this.dance_radius;
            
        end
        
        % Iterations
        function iterate(this)
            
            % Iterate based on algorithm type
            if this.is_standard()
                
                % Standard BA
                this.iterate_standard();
                
            else
                
                % Probabilistic BA
                this.iterate_probabilistic();
                
            end
            
            % Sort Population
            this.pop = this.sort_population(this.pop);
            
            % Update Best Solution Ever Found
            this.best_sol = this.pop(1);
            
            % Damp Dance Radius
            this.params.r = this.dance_radius_damp * this.params.r;
            
        end
        
        % Standard BA Iterator
        function iterate_standard(this)
            
            % Elite Sites
            for i = 1:this.elite_site_count
                
                % Create New Bees (Solutions)
                best_new_bee.obj_value = inf;
                for j = 1:this.elite_site_bee_count
                    xnew = this.perform_dance(this.pop(i).position);
                    new_bee = this.new_individual(xnew);
                    if this.is_better(new_bee, best_new_bee)
                        best_new_bee = new_bee;
                    end
                end
                
                % Compare to Best Solution Ever Found
                if this.is_better(best_new_bee, this.pop(i))
                    this.pop(i) = best_new_bee;
                end
                
            end

            % Selected Non-Elite Sites
            for i = this.elite_site_count+1:this.selected_site_count
                
                % Create New Bees (Solutions)
                best_new_bee.obj_value = inf;
                for j = 1:this.selected_site_bee_count
                    xnew = this.perform_dance(this.pop(i).position);
                    new_bee = this.new_individual(xnew);
                    if this.is_better(new_bee, best_new_bee)
                        best_new_bee = new_bee;
                    end
                end
                
                % Compare to Best Solution Ever Found
                if this.is_better(best_new_bee, this.pop(i))
                    this.pop(i) = best_new_bee;
                end
                
            end

            % Non-Selected Sites
            for i = this.selected_site_count+1:this.scout_bee_count
                this.pop(i) = this.new_individual();
            end
            
        end
        
        % Probabilistic BA Iterator
        function iterate_probabilistic(this)
            
            % Calculate Scores
            obj_values = this.get_objective_values(this.pop);
            if this.problem.is_maximization()
                F = obj_values;
            else
                F = 1./obj_values;
            end
            d = F/mean(F);
            
            % Iterate on Bees
            for i = 1:this.scout_bee_count
                
                % Determine Rejection Probability based on Score
                if d(i) < 0.9
                    reject_prob = 0.6;
                
                elseif d(i) >= 0.9 && d(i) < 0.95
                    reject_prob = 0.2;
                
                elseif d(i) >= 0.95 && d(i) < 1.15
                    reject_prob = 0.05;
                
                elseif d(i) >= 1.15
                    reject_prob = 0;
                
                end
                
                % Check for Acceptance/Rejection
                if rand >= reject_prob
                    % Acceptance
                    
                    % Calculate New Bees Count
                    bee_count = ceil(d(i)*this.recruited_bee_count);
                    
                    % Create New Bees (Solutions)
                    best_new_bee.obj_value = inf;
                    for j = 1:bee_count
                        xnew = this.perform_dance(this.pop(i).position);
                        new_bee = this.new_individual(xnew);
                        if this.is_better(new_bee, best_new_bee)
                            best_new_bee = new_bee;
                        end
                    end
                    
                    % Compare to Best Solution Ever Found
                    if this.is_better(best_new_bee, this.pop(i))
                        this.pop(i) = best_new_bee;
                    end
                    
                else
                    
                    % Rejection
                    this.pop(i) = this.new_individual();
                    
                end            

            end
            
        end
        
        % Perform Bee Dance
        function y = perform_dance(this, x)
            j = randi([1 numel(x)]);
            y = x;
            y(j) = x(j) + this.params.r * ypea_uniform_rand(-1, 1);
            y = ypea_clip(y, 0, 1);
        end
        
    end
    
end