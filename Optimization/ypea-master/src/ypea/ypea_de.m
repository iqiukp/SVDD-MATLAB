% Differential Evolution (DE)
classdef ypea_de < ypea_algorithm
    
    properties
        
        % Base Vector
        base_vector = 'rand';
        
        % Difference Vectors Count
        diff_vectors_count = 1;
        
        % Corssover Method
        crossover_method = 'bin';
        
        % Crossover Probability
        crossover_prob = 0.2;

        % Minimum Acceleration Coefficient
        beta_min = 0.2;
        
        % Maximum Acceleration Coefficient
        beta_max = 0.9;
        
    end
    
    properties (Dependent = true)

        % Type
        type;
        
    end
    
    methods
        
        % Constructor
        function this = ypea_de(type)
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Default Value fo Type
            if exist('type', 'var') && ~isempty(type)
                this.type = type;
            end
            
            % Set the Algorithm Name
            this.name = 'Differential Evolution';
            this.short_name = 'DE';
            
        end
        
        % Setter for Base Vector
        function set.base_vector(this, value)
            validateattributes(value, {'char', 'string'}, {});
            
            switch value
                case 'best'
                    this.base_vector = 'best';
                    
                case 'target-to-best'
                    this.base_vector = 'target-to-best';
                    
                case 'rand-to-best'
                    this.base_vector = 'rand-to-best';
                    
                otherwise
                    this.base_vector = 'rand';
                
            end
            
        end
        
        % Setter for Difference Vectors Count
        function set.diff_vectors_count(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', '>=', 1});
            this.diff_vectors_count = value;
        end
        
        % Setter for Crossover Probability
        function set.crossover_method(this, value)
            validateattributes(value, {'char', 'string'}, {});
            
            switch value
                case {'e', 'ex', 'exp', 'exponential'}
                    this.crossover_method = 'exp';
                    
                otherwise
                    this.crossover_method = 'bin';
                    
            end
            
        end
        
        % Getter for DE Algorithm Type
        function value = get.type(this)
            value = strjoin({'DE', ...
                             this.base_vector, ...
                             num2str(this.diff_vectors_count), ...
                             this.crossover_method}, '/');
        end
        
        % Setter for DE Algorithm Type
        function set.type(this, value)
            validateattributes(value, {'char', 'string'}, {});
            
            % Default Type
            value = strrep(value, ' ', '');
            value = strrep(value, '\', '/');
            if isempty(strrep(value, '/', ''))
                value = '';
            end
            if isempty(value)
                value = 'DE/rand/1/bin';
            end
            
            % Split Type Parts
            parts = strsplit(lower(value), '/', 'CollapseDelimiters', false);
            
            % Check first part and ignore it, if needed
            if strcmpi(parts{1}, 'DE')
                parts = parts(2:end);
            end
            if isempty(parts{1}) && numel(parts) >= 2 && isnan(str2double(parts{2}))
                parts = parts(2:end);
            end
            if ~isnan(str2double(parts{1}))
                parts = [{'rand'} parts];
            end
            
            % Dafault value for the first part
            if numel(parts)<1 || isempty(parts{1})
                parts{1} = 'rand';
            end
            
            % Default value for the second part
            if numel(parts)<2 || isempty(parts{2})
                parts{2} = '1';
            end
            
            % Default value for the third part
            if numel(parts)<3 || isempty(parts{3})
                parts{3} = 'bin';
            end
            
            % Set Base Vector
            this.base_vector = parts{1};
            
            % Set Number of Perturbation Vectors
            ndv = str2double(parts{2});
            if isnan(ndv)
                ndv = 1;
            end
            this.diff_vectors_count = max(round(ndv), 1);
            
            % Set Crossover Method
            this.crossover_method = parts{3};
                        
        end
        
        % Setter for Minimum Acceleration Coefficient
        function set.beta_min(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.beta_min = value;
        end
        
        % Setter for Maximum Acceleration Coefficient
        function set.beta_max(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.beta_max = value;
        end
        
        % Setter for Crossover Probability
        function set.crossover_prob(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', '<=', 1});
            this.crossover_prob = value;
        end
        
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)
            sorted = false;
            this.init_pop(sorted);
        end
        
        % Iterations
        function iterate(this)
            
            for i = 1:this.pop_size
                
                % Position of Selected Solution
                x = this.pop(i).position;
                
                % Perform Mutation
                y = this.perform_mutation(i);
                
                % Crossover
                z = this.perform_crossover(x, y);
                
                % Create and Evaluate New Solution
                newsol = this.new_individual(z);
                
                % Compare to Current Solution
                if this.is_better(newsol.obj_value, this.pop(i).obj_value)
                    
                    % Replace Current Solution
                    this.pop(i) = newsol;
                    
                    % Compare to Best Solution ever found
                    if this.is_better(this.pop(i), this.best_sol)
                        this.best_sol = this.pop(i);
                    end
                end
                
            end
            
        end
        
        % Perform Mutation
        function y = perform_mutation(this, i)

            % Decision Vector Size
            var_size = this.problem.var_size;
            
            % Number of Difference Vectors
            ndv = this.diff_vectors_count;
            
            % Acceleration Coefficient
            beta = @() ypea_uniform_rand(this.beta_min, this.beta_max, var_size);
            % beta = @() ypea_uniform_rand(this.beta_min, this.beta_max);
            
            % Number of Individuals Needed
            switch this.base_vector
                case {'rand', 'rand-to-best'}
                    ndv = min(ndv, floor((this.pop_size - 2)/2));
                    ns = 2*ndv + 1;
                    
                otherwise
                    ndv = min(ndv, floor((this.pop_size - 1)/2));
                    ns = 2*ndv;
                    
            end
            
            % Select Inidividuals
            A = randperm(this.pop_size);
            A(A==i) = [];
            A = A(1:ns);
            
            % Calculate Base Vector
            switch this.base_vector
                case 'rand'
                    xbase = this.pop(A(1)).position;
                    A = A(2:end);
                
                case 'best'
                    xbase = this.best_sol.position;
                    
                case 'target-to-best'
                    xbase = this.pop(i).position + beta().*(this.best_sol.position - this.pop(i).position);
                    
                case 'rand-ro-best'
                    xbase = this.pop(A(1)).position + beta().*(this.best_sol.position - this.pop(A(1)).position);
                    A = A(2:end);
                    
            end
            
            % Calculate Differences and Final Mutated Vector
            A = reshape(A, 2, []);
            a = A(1,:);
            b = A(2,:);
            y = xbase;
            for k = 1:numel(a)
                y = y + beta().*(this.pop(a(k)).position - this.pop(b(k)).position);
            end
            
        end
        
        function z = perform_crossover(this, x, y)
            
            n = numel(x);
            
            switch this.crossover_method
                case 'bin'
                    % Binomial Crossover
                    J = (rand(size(x)) <= this.crossover_prob);
                    J(randi(n)) = true;
                    
                case 'exp'
                    % Exponential Crossover
                    S = randi(n);
                    L = randi(n);
                    J = mod(S:S+L, n);
                    J(J==0) = n;
            end
            
            z = x;
            z(J) = y(J);
            
        end
        
    end
    
end