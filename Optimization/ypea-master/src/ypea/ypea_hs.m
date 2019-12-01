% Harmony Search (HS)
classdef ypea_hs < ypea_algorithm
    
    properties
        
        % New Harmony Count
        new_count = 20;
        
        % Harmony Memory Consideration Rate (HMCR)
        hmcr = 0.9;
        
        % Pitch Adjaustment Rate (PAR)
        par = 0.1;
        
        % Fret Width
        fret_width = 0.02;
        
        % Fret Width Damp Rate
        fret_width_damp = 0.99;
        
    end

    properties(Dependent = true)
        
        % Harmony Memory Size (alias of pop_size)
        hms;
        
    end
    
    methods
        
        % Constructor
        function this = ypea_hs()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Harmony Search';
            this.short_name = 'HS';
            
            % Initialize Harmony Memory Size (alias of Population Size)
            this.hms = 10;
            
        end
        
        % Getter for Harmony Memory Size (alias of pop_size)
        function value = get.hms(this)
            value = this.pop_size;
        end
        
        % Setter for Harmony Memory Size (alias of pop_size)
        function set.hms(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'positive'});
            this.pop_size = value;
        end
        
        % Setter for New Harmony Count
        function set.new_count(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'positive'});
            this.new_count = value;
        end
        
        % Setter for Harmony Memory Consideration Rate (HMCR)
        function set.hmcr(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', '<=', 1});
            this.hmcr = value;
        end
        
        % Setter for Pitch Adjaustment Rate (PAR)
        function set.par(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', '<=', 1});
            this.par = value;
        end
        
        % Setter for Fret Width (Mutation Step Size)
        function set.fret_width(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive', '<=', 1});
            this.fret_width = value;
        end
        
        % Setter for Fret Width Damp Rate
        function set.fret_width_damp(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'positive'});
            this.fret_width_damp = value;
        end
        
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)
            sorted = true;
            this.init_pop(sorted);
            this.params.fw = this.fret_width;
        end
        
        % Iteration
        function iterate(this)
            
            % Decision Vector Size
            var_size = this.problem.var_size;
            
            % Decision Variable Count
            var_count = this.problem.var_count;
            
            % Initialize Array for New Harmonies
            newpop = repmat(this.empty_individual, this.new_count, 1);
            
            % Create New Harmonies
            for k = 1:this.new_count

                % Create New Harmony Position
                newpop(k).position = rand(var_size);
                
                % Adjust New Harmony
                for j = 1:var_count
                    
                    % Use Harmony Memory
                    if rand <= this.hmcr
                        
                        i = randi([1 this.hms]);
                        newpop(k).position(j) = this.pop(i).position(j);
                        
                        % Pitch Adjustment
                        if rand <= this.par
                            delta = this.fret_width * randn();
                            newpop(k).position(j) = newpop(k).position(j) + delta;
                        end
                        
                    end
                    
                end
                
                % Clip Solution
                newpop(k).position = ypea_clip(newpop(k).position, 0, 1);
                
                % Evaluation
                newpop(k) = this.eval(newpop(k));
                
            end

            % Merge, Sort and Selection
            this.pop = this.sort_and_select([this.pop; newpop]);
            
            % Determine Best Solution
            this.best_sol = this.pop(1);
            
            % Damp Fret Width
            this.params.fw = this.fret_width_damp * this.params.fw;
            
        end
    end
    
end