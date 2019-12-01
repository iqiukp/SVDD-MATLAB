%% Genetic Algorithm
% This document shows how
% *Genetic Algorithm (GA)*
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

%% Genetic Algorithm
% Now, we are ready to create, initialize and utilize the
% Genetic Algorithm (GA)
% to solve the optimization problem, defined above.

%%
% First, we must create an instance of algorithm class:
alg = ypea_ga();

%%
% Let's set the parameters of the algorithm.

% Maximum Number of Iterations
alg.max_iter = 1000;

% Population Size
alg.pop_size = 100;

% Crossover Probability
alg.crossover_prob = 0.7;

% Crossover Inflation Factor
alg.crossover_inflation = 0.4;

% Mutation Probability
alg.mutation_prob = 0.3;

% Mutation Rate
alg.mutation_rate = 0.1;

% Mutation Step Size
alg.mutation_step_size = 0.5;

% Mutation Step Size Damp
alg.mutation_step_size_damp = 0.99;

% Selection Method
alg.selection = 'roulettewheel';

% Selection Pressure
alg.selection_pressure = 5;

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
