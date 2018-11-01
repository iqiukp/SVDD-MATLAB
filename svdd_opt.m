% DESCRIPTION
% Quadratic optimizer for the SVDD (modify on the basis of dd_tools)
%
%    [ALF] = SVDD_OPT(KER,X,C)
%
% INPUT
%   X         Train data
%   C         Fault tolerance rate
%   KER       Kernel function
%
% OUTPUT
%   ALF       Lagrange multipliers of support vetors



function [alf] = svdd_opt(ker,X,C)

% Setup the parameters for the optimization:
nrx = size(X,1);
labx = ones(nrx,1);

% Compute kernel matrix
K = computeKernelMatrix(ker,X,X);
D = (labx*labx').*K;
D = (D+D')/2; %  symmetric Hessian
f = labx.*diag(D);

% Quadratic programming
% Equality constraints:
A = labx';
b = 1.0;

% Lower and upper bounds:
lb = zeros(nrx,1);
ub = ones(nrx,1)*C(1);

% Initialization
p = 0.5*rand(nrx,1);

% These procedures *maximize* the functional L
opt = optimset('quadprog'); %opt.LargeScale='off';
opt.Algorithm = 'interior-point-convex';
opt.Display='off';
alf = quadprog(2.0*D,-f,[],[],A,b,lb,ub,p,opt);

% Lagrange multipliers of support vetors
alf = labx.*alf;

end


