% Covariance Matrix Adaptation Evolution Strategy (CMA-ES)
classdef ypea_cmaes < ypea_algorithm
    
    properties
        
        % Number of Offsprings
        mu;
        
    end
    
    properties(Dependent = true)
        
        % Population Size (alias of pop_size)
        lambda;
        
    end
    
    methods
        
        function this = ypea_cmaes()
            
            % Base Class Constructor
            this@ypea_algorithm();
            
            % Set the Algorithm Name
            this.name = 'Covariance Matrix Adaptation Evolution Strategy';
            this.short_name = 'CMA-ES';
            
            % Initialize Empty Individual Structure
            this.empty_individual = [];
            this.empty_individual.position = [];
            this.empty_individual.step = [];
            this.empty_individual.solution = [];
            this.empty_individual.obj_value = [];
            
            % Initial Value of Offsprings Count
            this.mu = round(this.lambda/2);
            
        end
        
        % Setter for Number of Offsprings (mu)
        function set.mu(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'positive'});
            this.mu = value;
        end
        
        % Getter for Population Size(lambda, alias of pop_size)
        function value = get.lambda(this)
            value = this.pop_size;
        end
        
        % Setter for Population Size(lambda, alias of pop_size)
        function set.lambda(this, value)
            validateattributes(value, {'numeric'}, {'scalar', 'integer', 'positive'});
            this.pop_size = value;
        end
        
    end
    
    methods(Access = protected)
        
        % Initialization
        function initialize(this)
            
            % Decision Variables Count
            var_count = this.problem.var_count;
            
            % Decision Vector Size
            var_size = this.problem.var_size;
            
            % Parent Weights
            w = log(this.mu + 0.5) - log(1:this.mu);
            w = w/sum(w);
            
            % Number of Effective Solutions
            mu_eff = 1/sum(w.^2);
            
            % Step Size Control Parameters (c_sigma and d_sigma);
            sigma0 = 0.3;
            cs = (mu_eff + 2)/(var_count + mu_eff + 5);
            ds = 1 + cs + 2*max(sqrt((mu_eff-1)/(var_count+1))-1,0);
            ENN = sqrt(var_count)*(1-1/(4*var_count)+1/(21*var_count^2));
            
            % Covariance Update Parameters
            cc = (4 + mu_eff/var_count)/(4 + var_count + 2*mu_eff/var_count);
            c1 = 2/((var_count+1.3)^2+mu_eff);
            alpha_mu = 2;
            cmu = min(1-c1,alpha_mu*(mu_eff-2+1/mu_eff)/((var_count+2)^2+alpha_mu*mu_eff/2));
            hth = (1.4+2/(var_count+1))*ENN;
            
            % Store Params
            this.params.w = w;
            this.params.mu_eff = mu_eff;
            this.params.sigma0 = sigma0;
            this.params.cs = cs;
            this.params.ds = ds;
            this.params.ENN = ENN;
            this.params.cc = cc;
            this.params.c1 = c1;
            this.params.alpha_mu = alpha_mu;
            this.params.cmu = cmu;
            this.params.hth = hth;
            
            % Initialize Step Sizes for Individuals
            this.empty_individual.step = zeros(var_size);
            
            % Initialize first Mean (M)
            this.params.M = repmat(this.empty_individual, this.max_iter, 1);
            this.params.M(1) = this.new_individual();
            
            % Initialize first Covariance Matrix (C)
            this.params.C = cell(this.max_iter, 1);
            this.params.C{1} = eye(var_count);
            
            % Initialize first pc
            this.params.pc = cell(this.max_iter, 1);
            this.params.pc{1} = zeros(var_size);
            
            % Initialize first ps
            this.params.ps = cell(this.max_iter, 1);
            this.params.ps{1} = zeros(var_size);
            
            % Initialize first Step Size (sigma)
            this.params.sigma = zeros(this.max_iter, 1);
            this.params.sigma(1) = sigma0;
            
            % Initialize Population
            this.pop = [];
            
            % Initialize Best Solution Ever Found
            this.best_sol = this.params.M(1);            
            
        end
        
        % Iterations
        function iterate(this)
            
            % Iteration Counter
            g = this.iter;
            
            % Decision Vector Size
            var_size = this.problem.var_size;
            
            % Load Parameters
            w = this.params.w;
            mu_eff = this.params.mu_eff;
            cs = this.params.cs;
            ds = this.params.ds;
            ENN = this.params.ENN;
            cc = this.params.cc;
            c1 = this.params.c1;
            cmu = this.params.cmu;
            hth = this.params.hth;
            M = this.params.M;
            C = this.params.C;
            pc = this.params.pc;
            ps = this.params.ps;
            sigma = this.params.sigma;
            
            % Generate Samples (New Solutinos)
            this.pop = repmat(this.empty_individual, this.lambda, 1);
            for i = 1:this.lambda
                
                this.pop(i).step = randn(var_size)*chol(C{g});
                this.pop(i).position = M(g).position + sigma(g)*this.pop(i).step;
                this.pop(i) = this.eval(this.pop(i));
                
                if this.is_better(this.pop(i), this.best_sol)
                    this.best_sol = this.pop(i);
                end
                
            end
            
            % Sort Population
            this.pop = this.sort_population(this.pop);
            
            if g < this.max_iter
                
                % Update Mean
                M(g+1).step = 0;
                for j = 1:this.mu
                    M(g+1).step = M(g+1).step + w(j)*this.pop(j).step;
                end
                M(g+1).position = M(g).position + sigma(g)*M(g+1).step;
                M(g+1) = this.eval(M(g+1));
                if this.is_better(M(g+1), this.best_sol)
                    this.best_sol = M(g+1);
                end
                
                % Update Step Size
                ps{g+1} = (1-cs)*ps{g} + sqrt(cs*(2-cs)*mu_eff)*M(g+1).step/chol(C{g})';
                sigma(g+1) = sigma(g)*exp(cs/ds*(norm(ps{g+1})/ENN-1))^0.3;
                
                % Update Covariance Matrix
                if norm(ps{g+1})/sqrt(1-(1-cs)^(2*(g+1))) < hth
                    hs=1;
                else
                    hs=0;
                end
                delta = (1-hs)*cc*(2-cc);
                pc{g+1} = (1-cc)*pc{g} + hs*sqrt(cc*(2-cc)*mu_eff)*M(g+1).step;
                C{g+1} = (1-c1-cmu)*C{g} + c1*(pc{g+1}'*pc{g+1} + delta*C{g});
                for j = 1:this.mu
                    C{g+1} = C{g+1} + cmu*w(j)*this.pop(j).step'*this.pop(j).step;
                end
                
                % If Covariance Matrix is not Positive Defenite or Near Singular
                [V, E] = eig(C{g+1});
                if any(diag(E)<0)
                    E = max(E,0);
                    C{g+1}=V*E/V;
                end
                
            end
            
            % Store Parameters
            this.params.M = M;
            this.params.C = C;
            this.params.pc = pc;
            this.params.ps = ps;
            this.params.sigma = sigma;
            
        end
        
    end
    
end