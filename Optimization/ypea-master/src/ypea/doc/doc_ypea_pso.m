%% Particle Swarm Optimization
% This document shows how
% *Particle Swarm Optimization (PSO)*
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

%% Particle Swarm Optimization
% Now, we are ready to create, initialize and utilize the
% Particle Swarm Optimization (PSO)
% to solve the optimization problem, defined above.

%%
% First, we must create an instance of algorithm class:
alg = ypea_pso();

%%
% Let's set the parameters of the algorithm.

% Maximum Number of Iterations
alg.max_iter = 100;

% Population Size
alg.pop_size = 100;

% Inertia Weight
alg.w = 0.5;

% Inertia Weight Damp Rate
alg.wdamp = 1;

% Personal Learning (Acceleration) Coefficient
alg.c1 = 1;

% Global Learning (Acceleration) Coefficient
alg.c2 = 2;

%%
% And now, we are ready to run the algorithm and solve the problem.
% The solve method, gets problem as input and returns |best_sol|, the best solution found
% by the algorithm.

best_sol = alg.solve(problem);

%%
% You may turn of the text output, by disabling the display property, just
% befor running the algorithm (i.e. calling |alg.solve(problem)|).
alg.display = false;

%%
% It is possible to use Constriction Coefficients* with PSO, by calling the
% following function, before running the algorithm.
phi1 = 2.05;
phi2 = 2.05;
alg.use_constriction_coeffs(phi1, phi2);

%%
% This function, changes the values of |w|, |c1| and |c2| as follows:
[alg.w, alg.c1, alg.c2]

%%
% Remember after changing these values, you should run the algorithm, by
% calling the |best_sol = alg.solve(problem)|.

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
