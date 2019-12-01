% Optimization Problem
classdef ypea_problem < handle
    
    properties
        
        % Objective Function
        obj_func = @(varargin) 0;
        
        % Decision Variables
        vars = [];
        
        % Type of the Problem (minimization or maximization)
        type = 'minimization';
        
        % Goal (Desired Value) for Objetive Value
        goal;
        
        % Maximum Number of Function Evaluations
        max_nfe;
        
    end
    
    properties(Dependent = true)
        
        % Worst Value of the Objective (based on problem type)
        worst_value;
        
        % Number of Decision Variables
        var_count;
        
        % Size of Decision Variables Vector
        var_size;
        
    end
    
    methods
        
        % Setter for Objective Function
        function set.obj_func(this, value)
            validateattributes(value, {'function_handle'}, {});
            this.obj_func = value;
        end
        
        % Setter for Problem Type
        function set.type(this, value)
            validateattributes(value, {'char'}, {});
            switch lower(value)
                case {'min', 'minimize', 'minimization'}
                    this.type = 'minimization';
                    
                case {'max', 'maximize', 'maximization'}
                    this.type = 'maximization';
                    
                otherwise
                    error('Optimization problem type must be minimization or maximization.');
            end
        end
        
        % Setter for Decision Variables
        function set.vars(this, value)
            validateattributes(value, {'struct'}, {});
            this.vars = value;
        end
        
        % Setter for Goal Value of Objective
        function set.goal(this, value)
            validateattributes(value, {'numeric'}, {'scalar'});
            this.goal = value;
        end
        
        % Setter for Max. NFE
        function set.max_nfe(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', 'integer'});
            this.max_nfe = value;
        end
        
        % Getter for Worst Objective Value
        function z = get.worst_value(this)
            if this.is_maximization()
                z = -inf;
            else
                z = inf;
            end
        end
        
        % Getter for Number of Decision Variables
        function n = get.var_count(this)
            if ~isempty(this.vars)
                n = ypea_get_total_code_length(this.vars);
            else
                n = 0;
            end
        end
        
        % Getter for Decision Variables Vector Size
        function s = get.var_size(this)
            s = [1 this.var_count];
        end
        
        % Generate Random Solution
        function xhat = rand_sol(this)
            xhat = rand(this.var_size);
        end
        
        % Generate, Decode and Evaluate Random Solution
        function [xhat, z, sol] = rand_sol_eval(this)
            xhat = this.rand_sol();
            [z, sol] = this.decode_and_eval(xhat);
        end
        
        % Decode (Parse) Coded Solution
        function sol = decode(this, xhat)
            sol = ypea_decode_solution(this.vars, xhat);
        end
        
        % Evaluate Solution
        function z = eval(this, sol)
            z = this.obj_func(sol);
        end
        
        % Decode and Evaluate Coded Solution
        function [z, sol] = decode_and_eval(this, xhat)
            sol = this.decode(xhat);
            z = this.eval(sol);
        end
        
        % Check if Problem is Minimization
        function b = is_minimization(this)
            b = strcmpi(this.type, 'minimization');
        end
        
        % Check if Problem is Maximization
        function b = is_maximization(this)
            b = strcmpi(this.type, 'maximization');
        end
        
        % Check if a solution is better than other
        function b = is_better(this, x1, x2)
            
            % Get obj_value field, if solution is structure
            if isstruct(x1) && isfield(x1, 'obj_value')
                x1 = x1.obj_value;
            end
            if isstruct(x2) && isfield(x2, 'obj_value')
                x2 = x2.obj_value;
            end
            
            % Compare Solutions
            if this.is_maximization()
                b = (x1 >= x2);
            else
                b = (x1 <= x2);
            end
            
        end
        
        % Get Sorting Direction
        function direction = sort_direction(this)
            if this.is_maximization()
                direction = 'descend';
            else
                direction = 'ascend';
            end
        end
        
        % Find Best of Array
        function [m, ind] = find_best(this, obj_values)
            if this.is_maximization()
                finder = @max;
            else
                finder = @min;
            end
            [m, ind] = finder(obj_values);
        end
        
        % Find Worst of Array
        function [m, ind] = find_worst(this, obj_values)
            if this.is_maximization()
                finder = @min;
            else
                finder = @max;
            end
            [m, ind] = finder(obj_values);
        end
        
    end
    
end