% Yarpiz Evolutionary Computation Toolbox (YPEA)
%
% Evolutionary Algorithms and Metaheuristics
%   ypea_algorithm                        - Abstract Evolutionary Algorithm (Abs. EA)
%   ypea_abc                              - Artificial Bee Colony (ABC)
%   ypea_acor                             - Continuous Ant Colony Optimization (ACOR)
%   ypea_ba                               - Bees Algorithm (BA)
%   ypea_bbo                              - Biogeography-based Optimization (BBO)
%   ypea_cmaes                            - Covariance Matrix Adaptation Evolution Strategy (CMA-ES)
%   ypea_de                               - Differential Evolution (DE)
%   ypea_fa                               - Exponent
%   ypea_ga                               - Genetic Algorithm (GA)
%   ypea_hs                               - Harmony Search (HS)
%   ypea_ica                              - Imperialist Competitive Algorithm (ICA)
%   ypea_iwo                              - Invasive Weed Optimization (IWO)
%   ypea_pso                              - Particle Swarm Optimization (PSO)
%   ypea_sa                               - Simulated Annealing (SA)
%   ypea_tlbo                             - Teaching-Learning-based Optimization (TLBO)
%
% Optimization Problems and Test Functions
%   ypea_problem                          - Optimization Problem
%   ypea_test_function                    - Ruturns function handle to predefined benchmark functions
%
% Decision Variables
%   ypea_var                              - Creates a Decision Variable Definition
%   ypea_decode_solution                  - Decodes a coded vector and converts to structured solution
%   ypea_define_var_type_binary           - Defines the 'binary' decision variable type
%   ypea_define_var_type_binary_partition - Defines the 'binary_partition' decision variable type
%   ypea_define_var_type_binary_selection - Defines the 'binary_selection' decision variable type
%   ypea_define_var_type_fixed_column_sum - Defines the fixed 'column_sum' decision variable type
%   ypea_define_var_type_fixed_row_sum    - Defines the fixed 'row_sum' decision variable type
%   ypea_define_var_type_fixed_sum        - Defines the fiexd 'sum' decision variable type
%   ypea_define_var_type_integer          - Defines the 'integer' decision variable type
%   ypea_define_var_type_partition        - Defines the 'partition' decision variable type
%   ypea_define_var_type_permutation      - Defines the 'permutation' decision variable type
%   ypea_define_var_type_real             - Defines the 'real' decision variable type
%   ypea_define_var_type_selection        - Defines the 'selection' decision variable type
%   ypea_generate_sample                  - Generates a Sample of a Given Variable or Variable Set (Array)
%   ypea_generate_sample_code             - Generate Coded Solution for a Given Variable or Variable Set (Array)
%   ypea_get_defined_var_types            - Gathers Variable Types Defined in YPEA Toolbox
%   ypea_get_total_code_length            - Ruturns the Length of Coded Vectors Related to a Variable Set (Array)
%   ypea_get_var_code_size                - Calculates the Size of Code for a Variable
%   ypea_get_var_type                     - Determines the Type of a Decision Variable
%
% Misc. Functions
%   ypea_version                          - Returns Version of YPEA Toolbox
%   ypea_path                             - Returns installation directory of YPEA Toolbox
%   ypea_clip                             - Clips the inputs, and ensures the lower and upper bounds.
%   ypea_is_in_range                      - Checks if a value is within a range or not
%   ypea_uniform_rand                     - Generate Uniformly Distributed Random Numbers
%   ypea_rand_sample                      - Randomly selecting k samples from n items
%   ypea_roulette_wheel_selection         - Performs Roulette Wheel Selection
%   ypea_simplify_string                  - Simplifies a String
%   ypea_normalize_probs                  - Normalize Probabilities
%
