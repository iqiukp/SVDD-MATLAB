% Imperialist Competitive Algorithm (ICA)
classdef ypea_ica < ypea_algorithm
    
    properties
        
        % Number of Empires (also Imperialists)
        empire_count = 5;
        
        % Selection Pressure
        selection_pressure = 1;
        
        % Assimilation Coefficient
        assimilation_coeff = 1.5;
        
        % Revolution Probability
        revolution_prob = 0.05;
        
        % Revolution Rate
        revolution_rate = 0.1;
        
        % Revolution Step Size
        revolution_step_size = 0.1;
        
        % Revolution Step Size Damp Rate
        revolution_step_size_damp = 0.99;
        
        % Colonies Coefficient in Total Objective Value of Empires
        zeta = 0.2;
        
    end
    
    properties(Dependent = true)
        
        % Total Number of Colonies
        colony_count;
        
    end
    
    properties(SetAccess = protected, Dependent = true)
        
        % Empires (alias of pop)
        emp;
        
    end
    
    methods
        
        % Constructor
        function this = ypea_ica()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Imperialist Competitive Algorithm';
            this.short_name = 'ICA';
            
        end
        
        % Setter for Empire Count (also Imperialist Count)
        function set.empire_count(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'positive', '>=', 2, '<', this.pop_size});
            this.empire_count = value;
        end
        
        % Getter for Colony Count
        function value = get.colony_count(this)
            value = this.pop_size - this.empire_count;
        end
        
        % Getter for Empires
        function value = get.emp(this)
            value = this.pop;
        end
        
        % Setter for Empires
        function set.emp(this, value)
            this.pop = value;
        end
        
        % Setter for Selection Pressure
        function set.selection_pressure(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.selection_pressure = value;
        end
        
        % Setter for Assimilation Coeficient
        function set.assimilation_coeff(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.assimilation_coeff = value;
        end
        
        % Setter for Revolution Probability
        function set.revolution_prob(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative', '<=', 1});
            this.revolution_prob = value;
        end
        
        % Setter for Revolution Rate
        function set.revolution_rate(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative', '<=', 1});
            this.revolution_rate = value;
        end
        
        % Setter for Revolution Step Size
        function set.revolution_step_size(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative', '<=', 1});
            this.revolution_step_size = value;
        end
        
        % Setter for Revolution Step Size Damp Rate
        function set.revolution_step_size_damp(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.revolution_step_size_damp = value;
        end
        
        % Setter for Colonies Coefficient in Empires Objective Value
        function set.zeta(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.zeta = value;
        end
                
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)
            
            % Create Initial Population (Sorted)
            sorted = true;
            this.init_pop(sorted);
            
            % Determine Imperialists and Colonies
            pop = this.pop;
            imp = pop(1:this.empire_count);
            col = pop(this.empire_count+1:end);
            
            % Empty Empire
            empty_empire.imp = [];
            empty_empire.col = repmat(this.empty_individual, 0, 1);
            empty_empire.colony_count = 0;
            empty_empire.total_obj_value = [];
            
            % Initialize Empires
            this.emp = repmat(empty_empire, this.empire_count, 1);
            
            % Assign Imperialists
            for k = 1:this.empire_count
                this.emp(k).imp = imp(k);
            end
            
            % Determine Selection Probabilities
            obj_values = [imp.obj_value];
            obj_values = obj_values/max(abs(obj_values));
            P = this.get_selection_probs(obj_values, this.selection_pressure);
            
            % Assign Colonies
            for j = 1:this.colony_count
                k = ypea_roulette_wheel_selection(P);
                this.emp(k).col = [this.emp(k).col; col(j)];
                this.emp(k).colony_count = numel(this.emp(k).col);
            end
            
            % Initial Value of Step Size
            this.params.sigma = this.revolution_step_size;
            
            % Update Total Objective Values of Empires
            this.update_empires_total_objective_values();
            
        end
        
        function iterate(this)
            
            % Assimilation
            this.assimilation();
            
            % Revolution
            this.revolution();
            
            % Intra-Empire Competition
            this.intra_empire_competition();

            % Update Total Objective Values of Empires
            this.update_empires_total_objective_values();

            % Inter-Empire Competition
            this.inter_empire_competition();
            
            % Update Revolution Step Size
            this.params.sigma = this.revolution_step_size_damp * this.params.sigma;
            
        end
        
        function update_empires_total_objective_values(this)

            for k = 1:numel(this.emp)
                if this.emp(k).colony_count > 0
                    this.emp(k).total_obj_value = this.emp(k).imp.obj_value ...
                        + this.zeta*mean([this.emp(k).col.obj_value]);
                else
                    this.emp(k).total_obj_value = this.emp(k).imp.obj_value;
                end
            end

        end        
        
        function assimilation(this)
            
            % Decision Vector Size
            var_size = this.problem.var_size;
            
            % Assimilation Coefficient
            beta = this.assimilation_coeff;
            
            % Assimilate Colonies
            for k = 1:numel(this.emp)
                for i = 1:this.emp(k).colony_count
                    
                    % Create New Solution
                    this.emp(k).col(i).position = this.emp(k).col(i).position ...
                        + beta*rand(var_size).*(this.emp(k).imp.position - this.emp(k).col(i).position);
                    
                    % Evaluation
                    this.emp(k).col(i) = this.eval(this.emp(k).col(i));
                    
                    % Compare to Best Solution Ever Found
                    if this.is_better(this.emp(k).col(i), this.best_sol)
                        this.best_sol = this.emp(k).col(i);
                    end
                    
                end
            end
            
        end
        
        function revolution(this)
            
            % Decision Vector Size
            var_size = this.problem.var_size;
            
            % Decision Variables Count
            var_count = this.problem.var_count;
            
            % Revolution Rate
            mu = this.revolution_rate;
            
            % Number of Revoluted Decision Variables
            nmu = ceil(mu*var_count);
            
            % Revolution Step Size
            sigma = this.params.sigma;
            
            % Revolve Imperialists and Colonies
            for k = 1:numel(this.emp)
                
                % Apply Revolution to Imperialist
                xnew = this.emp(k).imp.position + sigma*randn(var_size);
                jj = ypea_rand_sample(var_count, nmu);
                newimp = this.emp(k).imp;
                newimp.position(jj) = xnew(jj);
                newimp = this.eval(newimp);
                if this.is_better(newimp, this.emp(k).imp)
                    this.emp(k).imp = newimp;
                    if this.is_better(this.emp(k).imp, this.best_sol)
                        this.best_sol = this.emp(k).imp;
                    end
                end
                
                % Apply Revolution to Colonies
                for i = 1:this.emp(k).colony_count
                    if rand <= this.revolution_prob
                        xnew = this.emp(k).col(i).position + sigma*randn(var_size);
                        jj = ypea_rand_sample(var_count, nmu);
                        this.emp(k).col(i).position(jj) = xnew(jj);
                        this.emp(k).col(i) = this.eval(this.emp(k).col(i));
                        if this.is_better(this.emp(k).col(i), this.best_sol)
                            this.best_sol = this.emp(k).col(i);
                        end
                    end
                end
            end
            
        end
        
        function intra_empire_competition(this)
            
            for k = 1:numel(this.emp)
                for i = 1:this.emp(k).colony_count
                    
                    % Compare Colonies of Empires to Corresponding Imperialist
                    if this.is_better(this.emp(k).col(i), this.emp(k).imp)
                        
                        % If colony is better, then swap colony and imp.
                        
                        imp = this.emp(k).imp;
                        col = this.emp(k).col(i);
                        
                        this.emp(k).imp = col;
                        this.emp(k).col(i) = imp;
                        
                    end
                    
                end
            end
            
        end

        function inter_empire_competition(this)

            % In case of one empire, inter-empire competition is not needed
            if numel(this.emp) == 1
                return;
            end
            
            % Gather and Normalize Total Objective Values
            total_obj_values = [this.emp.total_obj_value];
            total_obj_values = total_obj_values/max(abs(total_obj_values));
            
            % Find Weakest Empire
            [~, weakest_empire_index] = this.problem.find_worst(total_obj_values);
            weakest_empire = this.emp(weakest_empire_index);
            
            % Calculate Selection Probabilities
            P = this.get_selection_probs(total_obj_values, this.selection_pressure);
            P(weakest_empire_index)=0;
            P = ypea_normalize_probs(P);
            
            % If the weakset empire has any colonies
            if weakest_empire.colony_count > 0
                
                % Find Weakest Colony of th Weakest Empire
                [~, weakest_colony_index] = this.problem.find_worst([weakest_empire.col.obj_value]);
                weakest_col = weakest_empire.col(weakest_colony_index);
                
                winner_empire_index = ypea_roulette_wheel_selection(P);
                winner_empire = this.emp(winner_empire_index);

                winner_empire.col(end+1) = weakest_col;
                winner_empire.colony_count = numel(winner_empire.col);
                this.emp(winner_empire_index) = winner_empire;
                
                weakest_empire.col(weakest_colony_index)=[];
                weakest_empire.colony_count = numel(weakest_empire.col);
                this.emp(weakest_empire_index) = weakest_empire;
                
            end
            
            % If the weakest empire has no colonies
            if weakest_empire.colony_count == 0
                
                winner_empire_index_2 = ypea_roulette_wheel_selection(P);
                winner_empire_2 = this.emp(winner_empire_index_2);

                winner_empire_2.col(end+1) = weakest_empire.imp;
                this.emp(winner_empire_index_2) = winner_empire_2;

                this.emp(weakest_empire_index)=[];
            end
            
        end        
        
    end
    
end