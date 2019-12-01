%% Differential Evolution
% This document shows how
% *Differential Evolution (DE)*
% as a part of Yarpiz Evolutionary Algorithms Toolbox (YPEA)
% cab be used to solve optimization problems.

%% Problem Definition
% First of all, we need to define optimization problem. We must define the
% search space (decision variables) and objective function.

%%
% Let's ceate an instance of optimization problem.
problem = ypea_problem();

%%
% Assume that the problem is to find 20 real numbers, in range -10 to 10.
problem.vars = ypea_var('x', 'real', 'size', 20, 'lower_bound', -10, 'upper_bound', 10);

%%
% And, the objective is to minimize the well-known _sphere_ function
% in this domain.
sphere = ypea_test_function('sphere');
problem.obj_func = @(sol) sphere(sol.x);

%%
% To get more information on the optimization problems and decision variables,
% you can go to
% <doc_ypea_problem.html Optimization Problems> and
% <doc_ypea_var.html Decision Variables>.

%% Differential Evolution
% Now, we are ready to create, initialize and utilize the
% Differential Evolution (DE)
% to solve the optimization problem, defined above.

%%
% Firstly, we must create an instance of algorithm class.
% According to the conventions found in the literature of
% Differential Evolution (DE), we are using the |DE/best/2/exp| version,
% which means:
% 
% * the base vector of mutation, is the best solution ever found,
% * two vector differences are used (i.e. four random solutions have
% contribution in creation of mutated vector),
% * and exponential crossover is utilized.
% 
alg = ypea_de('DE/best/2/exp');

%%
% Some other available configurations are listed below:
%
% * |DE/rand/1/bin| (default)
% * |DE/rand-to-best/1/exp|
% * |DE/target-to-best/3/bin|
% * |DE/best/1/bin|
% * |DE/rand/5/exp|
%

%%
% Let's set the parameters of the algorithm.

% Maximum Number of Iterations
alg.max_iter = 1000;

% Population Size
alg.pop_size = 20;

% Minimum Value of Acceleration Coefficient
alg.beta_min = 0.1;

% Maximum Value of Acceleration Coefficient
alg.beta_max = 0.9;

% Crossover Probability
alg.crossover_prob = 0.1;

%%
% And now, we are ready to run the algorithm and solve the problem.
% The solve method, gets problem as input and returns |best_sol|, the best solution found
% by the algorithm.

best_sol = alg.solve(problem);

%%
% You may turn of the text output, by disabling the display property, just
% befor running the algorithm (i.e. calling |alg.solve(problem)|).
alg.display = false;

%% Results

%%
% The actual solution, is stored in the |solution| field of |best_sol|.

best_sol.solution

%%
% The values of 20 decision variables, denoted by |x| is as follows:
best_sol.solution.x

%%
% and the related objective value is:
best_sol.obj_value

%%
% Total run time of the algorithm is given by (in seconds):
alg.run_time

%%
% and total number of function evaluations is given by:
alg.nfe

%%
% We can illustrate the result of optimization process by plotting
% best objective value history (|alg.best_obj_value_history|)
% vs. number of function evaluations (|alg.nfe_history|).

figure;
alg.semilogy('nfe', 'LineWidth', 2);
xlabel('NFE');
ylabel('Best Objective Value');
title(['Results of ' alg.full_name]);
grid on;
