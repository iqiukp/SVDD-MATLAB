% Particle Swarm Optimization (PSO)
classdef ypea_pso < ypea_algorithm
    
    properties
        
        % Inertia Weight
        w = 1;
        
        % Inertia Weight Damp Rate
        wdamp = 0.99;
        
        % Personal Acceleration Coefficient
        c1 = 2;
        
        % Global Acceleration Coefficient
        c2 = 2;
        
    end
    
    methods
        
        % Constructor
        function this = ypea_pso()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Particle Swarm Optimization';
            this.short_name = 'PSO';
            
            % Initialize Emprt Prticle (Individual)
            this.empty_individual = [];
            this.empty_individual.position = [];
            this.empty_individual.velocity = [];
            this.empty_individual.obj_value = [];
            this.empty_individual.solution = [];
            this.empty_individual.best.position = [];
            this.empty_individual.best.obj_value = [];
            this.empty_individual.best.solution = [];
            
        end
        
        % Setter for Inertia Weight
        function set.w(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.w = value;
        end
        
        % Setter for Inertia Weight Damp Rate
        function set.wdamp(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', '<=', 1});
            this.wdamp = value;
        end
        
        % Setter for Personal Acceleration Coefficient
        function set.c1(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.c1 = value;
        end
        
        % Setter for Global Acceleration Coefficient
        function set.c2(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'nonnegative'});
            this.c2 = value;
        end
        
        % Make Use of Constriction Coefficients
        function use_constriction_coeffs(this, phi1, phi2)
            
            % Checing values of phi1 and phi2
            
            if ~exist('phi1', 'var')
                phi1 = [];
            else                
                validateattributes(phi1, {'numeric'}, {'scalar', 'nonnegative'});
            end
            
            if ~exist('phi2', 'var')
                phi2 = [];
            else
                validateattributes(phi2, {'numeric'}, {'scalar', 'nonnegative'});
            end
            
            if ~isempty(phi1)
                if ~isempty(phi2)
                    if phi1 + phi2 == 0
                        phi1 = 2.05;
                        phi2 = 2.05;
                    end
                else
                    phi2 = phi1;
                end
            else
                if ~isempty(phi2)
                    phi1 = phi2;
                else
                    phi1 = 2.05;
                    phi2 = 2.05;
                end
            end
            
            % Ensure than phi1 + phi2 is greater than or equal to 4.
            if phi1 + phi2 < 4
                phi = phi1 + phi2;
                phi1 = phi1/phi*4;
                phi2 = phi2/phi*4;
            end
            
            % Calculate Constriction Coefficients
            phi = phi1 + phi2;
            chi = 2 / (phi - 2 + sqrt(phi^2 - 4*phi));
            this.w = chi;
            this.wdamp = 1;
            this.c1 = chi*phi1;
            this.c2 = chi*phi2;
        end
        
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)
            
            % Initialize Velocity Vector
            this.empty_individual.velocity = zeros(this.problem.var_size);
            
            % Create Initial Population (Not Sorted)
            sorted = false;
            this.init_pop(sorted);
            
            % Initialize Personal Bests
            for i = 1:this.pop_size
                this.pop(i).best.position = this.pop(i).position;
                this.pop(i).best.solution = this.pop(i).solution;
                this.pop(i).best.obj_value = this.pop(i).obj_value;
            end
            
            % Initial Value of Inertia Weight
            this.params.w = this.w;
            
        end
        
        % Iterations
        function iterate(this)
            
            % Decision Vector Size
            var_size = this.problem.var_size;
            
            % Move Particles
            for i = 1:this.pop_size
                
                % Update Velocity
                this.pop(i).velocity = this.params.w * this.pop(i).velocity ...
                    + this.c1 * rand(var_size).*(this.pop(i).best.position - this.pop(i).position) ...
                    + this.c2 * rand(var_size).*(this.best_sol.position - this.pop(i).position);
                
                % Update Position
                this.pop(i).position = this.pop(i).position + this.pop(i).velocity;
                
                % Mirror Velocities in Case of Limit Violation
                mirror_flag = (this.pop(i).position < 0) | (this.pop(i).position > 1);
                this.pop(i).velocity(mirror_flag) = -this.pop(i).velocity(mirror_flag);
                
                % Evaluate New Solution
                this.pop(i) = this.eval(this.pop(i));
                
                % Comapre to Personal Best
                if this.is_better(this.pop(i).obj_value, this.pop(i).best.obj_value)
                    
                    % Update Personal Best
                    this.pop(i).best.position = this.pop(i).position;
                    this.pop(i).best.solution = this.pop(i).solution;
                    this.pop(i).best.obj_value = this.pop(i).obj_value;
                    
                    % Compare to Global Best
                    if this.is_better(this.pop(i).best, this.best_sol)
                        this.best_sol = this.pop(i).best;
                    end
                end
                
            end
            
            % Damp Inertia Weight
            this.params.w = this.wdamp * this.params.w;
            
        end
    end
    
end