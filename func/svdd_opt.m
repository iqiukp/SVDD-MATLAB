% DESCRIPTION
% Quadratic optimizer for SVDD 
%
%    alf = svdd_opt(K,X,C)
%
% INPUT
%   K         Kernel matrix
%   X         Training data
%   C         Trade-off parameter
%
% OUTPUT
%   alf       Lagrange multipliers of support vetors

% Created by Kepeng Qiu on May 28, 2019.
%-------------------------------------------------------------%

function alf = svdd_opt(K,X,C)

%
N = size(X,1);

% Symmetric Hessian
labx = ones(N,1);
D = (labx*labx').*K;
D = (D+D')/2;
f = labx.*diag(D);

% Equality constraints
A = labx';
b = 1.0;

% Lower and upper bounds
lb = zeros(N,1);
ub = ones(N,1)*C(1);

% Initialization
p = 0.5*rand(N,1);

% Quadratic optimize
opt = optimset('quadprog'); 
opt.Algorithm = 'interior-point-convex';
opt.Display='off';
alf = quadprog(2.0*D,-f,[],[],A,b,lb,ub,p,opt);

end


