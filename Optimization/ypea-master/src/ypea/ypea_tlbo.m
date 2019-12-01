% Teaching-Learning-based Optimization (TLBO)
classdef ypea_tlbo < ypea_algorithm
    
    methods
        
        % Constructor
        function this = ypea_tlbo()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Teaching-Learning-based Optimization';
            this.short_name = 'TLBO';
            
        end
                
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)
            
            % Create Initial Population (Not Sorted)
            sorted = false;
            this.init_pop(sorted);
            
        end
        
        % Iterations
        function iterate(this)
            
            % Decision Vector Size
            var_size = this.problem.var_size;
            
            % Calculate Population Mean
            the_mean = mean(this.get_positions(this.pop));

            % Select Teacher
            teacher = this.get_population_best(this.pop);
            
            % Teacher Phase
            for i = 1:this.pop_size
                
                % Teaching Factor
                TF = randi([1 2]);

                % Teaching (moving towards teacher)
                xnew = this.pop(i).position + rand(var_size).*(teacher.position - TF * the_mean);
                
                % Create New Solution
                newsol = this.new_individual(xnew);
                
                % Compare and Update
                if this.is_better(newsol, this.pop(i))
                    this.pop(i) = newsol;
                    if this.is_better(this.pop(i), this.best_sol)
                        this.best_sol = this.pop(i);
                    end
                end
                
            end

            % Learner Phase
            for i = 1:this.pop_size
                
                % Select Target
                A = 1:this.pop_size;
                A(i)=[];
                j = A(randi(this.pop_size-1));
                
                % Determine Step
                step = this.pop(i).position - this.pop(j).position;
                if this.is_better(this.pop(j), this.pop(i))
                    step = -step;
                end
                
                % Teaching (moving towards teacher)
                xnew = this.pop(i).position + rand(var_size).*step;

                % Create New Solution
                newsol = this.new_individual(xnew);
                
                % Compare and Update
                if this.is_better(newsol, this.pop(i))
                    this.pop(i) = newsol;
                    if this.is_better(this.pop(i), this.best_sol)
                        this.best_sol = this.pop(i);
                    end
                end                

            end            
                        
        end
    end
    
end