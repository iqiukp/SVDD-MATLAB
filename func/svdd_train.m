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
%   ker       Kernel function
%
% OUTPUT
%   model         SVDD hypersphere
%
% Created by Kepeng Qiu on May 28, 2019.
%-------------------------------------------------------------%

function model = svdd_train(X,C,ker)

%
SV_threshold = 1e-8;
C = [C,Inf];

% Compute the kernel matrix
K = computeKM(ker,X,X);

% Quadratic optimizer for SVDD 
alf = svdd_opt(K,X,C);

% support vectors 
SV_index = find(alf>SV_threshold);
SV_value = X(SV_index,:);
SV_alf = alf(SV_index);

% Compute the center: eq(7)
cent = alf'*X; 

% Compute the radius: eq(15)
% The distance from any support vector to the center of the sphere is 
% the hypersphere radius. Here take the first support vector.

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