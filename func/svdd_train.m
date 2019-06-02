% DESCRIPTION
% Train SVDD hypersphere
% reference: Tax, David MJ, and Robert PW Duin.
% "Support vector data description." Machine learning 54.1 (2004): 45-66.
%
%       model = svdd_train(X,C,ker)
%
% INPUT
%   X         Training data
%   C         trade-off parameter
%   ker       Kernel function parameters
%
% OUTPUT
%   model         SVDD hypersphere
%
% Created by Kepeng Qiu on Jun 2, 2019.
%-------------------------------------------------------------%

function model = svdd_train(X,C,ker)

% The value of C should be chosen in [1/N, 1], where N is the number 
% of data. Models with C>1 are the same, and so are models with C<1/N.
if C < 1/size(X,1)
    C = 1/size(X,1)+eps;
end

% Compute the kernel matrix
K = computeKM(ker,X,X);

% Solve the Lagrange dual problem of SVDD by using SMO
alf = svdd_smo(K,C);

% support vectors
SV_index = find(alf>eps);
SV_value = X(SV_index,:);
SV_alf = alf(SV_index);

% Compute the center: eq(7)
cent = alf'*X;

% Compute the radius: eq(15)
% The distance from any support vector to the center of the sphere is
% the hypersphere radius. Here take the 1st support vector.

r_index = SV_index(1,1);
% the 1st term in eq(15)
term1 = K(r_index,r_index);
% the 2nd term in eq(15)
term2 = -2*K(r_index,:)*alf;
% the 3rd term in eq(15)
term3 = sum(sum((alf *alf').*K));
% radius
R = term1+term2+term3;

% Store the results
model.X = X;
model.ker = ker;
model.SV_alf = SV_alf;
model.R = R;
model.SV_value = SV_value;
model.SV_index = SV_index;
model.cent = cent;
model.term3 = term3;
model.alf = alf;

end