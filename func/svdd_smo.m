% DESCRIPTION
% Solve the Lagrange dual problem of SVDD by using SMO
% reference: https://github.com/JasonXu12/SVM-and-Machine-Learning
%
%       alf = svdd_smo(K,C)
%
% INPUT
%   K         kernel matrix
%   C         trade-off parameter
%
% OUTPUT
%   alf       Lagrange multipliers
%
% Modified by Kepeng Qiu on Jun 2, 2019.
%-------------------------------------------------------------%

function alf = svdd_smo(K,C)

% Initialize 'alf'
N = size(K,1);
alf = ones(N,1)/N;

% Initialize 'g'
% g(i) is the partial derivative of the objective function of the dual
% problem to alf(i)
g = diag(K);

% g = g-(sum(alf.*K,1))'-alf.*g;
g = g-(sum(repmat(alf,1,N).*K,1))'-alf.*g;


%
[gmax,i] = max(g);
[gmin,j] = min(g);
delta = gmax-gmin;
tor = 1e-5;
iter = 0;
max_iter = 1000;

%
while(delta>=tor && iter<max_iter)
    % Compute the step
    tmp = [C-alf(i,1) alf(j,1) (g(i,1)-g(j,1))/(K(i,i)+K(j,j)-2*K(i,j))];
    L = min(tmp);
    
    % Update the partial derivative
    g = g-L*K(:,i)+L*K(:,j);
    
    % Update the Lagrange multipliers
    alf(i,1) = alf(i,1)+L;
    alf(j,1) = alf(j,1)-L;
    
    % Choose the working set
    IDi = find(alf<C-eps);
    IDj = find(alf>eps);
    [gmax,IDix] = max(g(IDi,1));
    i = IDi(IDix(1));
    [gmin,IDjx] = min(g(IDj,1));
    j = IDj(IDjx(1));
    
    % Compute the error
    delta = gmax-gmin;
    iter = iter+1;
end
end


