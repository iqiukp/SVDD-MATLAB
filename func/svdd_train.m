% DESCRIPTION
% Train SVDD hypersphere  
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
% Created by Kepeng Qiu on May 24, 2019.
%-------------------------------------------------------------%

function model = svdd_train(X,C,ker)

%
SV_threshold = 1e-8;
C = [C,Inf];

% Compute the kernel matrix
K = computeKM(ker,X,X);
alf = svdd_opt(K,X,C);

% support vectors 
SV_index = find(alf>SV_threshold);
SV_value = X(SV_index,:);
SV_alf = alf(SV_index);

% Compute the center
cent = SV_alf'*SV_value;

% Distance to center of the sphere (ignoring the offset):
K_SV = computeKM(ker,SV_value,SV_value);
Dx = - 2*sum( (ones(size(SV_index,1),1)*SV_alf').*K_SV, 2);

% Compute the offset 
offs = 1 + sum(sum((SV_alf *SV_alf').*computeKM(ker,SV_value,SV_value)));

% Compute the threshold
threshold = offs+mean(Dx);

% Store the results
model.ker = ker;
model.SV_alf = SV_alf;
model.threshold = threshold;
model.SV_value = SV_value;
model.offs = offs;
model.SV_index = SV_index;
model.cent = cent;

end