% DESCRIPTION
% SVDD hypersphere train (modify on the basis of dd_tools)
%
%       W = SVDD(X,C,ker)
%
% INPUT
%   X         One-class dataset
%   C         Fault tolerance rate
%   ker       Kernel function
%
% OUTPUT
%   MODEL         SVDD hypersphere
% Created on 1st November, 2018, by Kepeng Qiu.

function model = svdd_train(X,D,ker)

% Accroding to the equation: C = 1/(N*D),
% N is the number of samples and D is the fault tolerance rate

C = [1/(size(X,1)*D),Inf];

% Solution to optimization problem
[alf] = svdd_opt(ker,X,C);

% The support vectors and errors:
I = find(abs(alf)>1e-8);

% Support vetor dataset
SV = X(I,:);
alf_SV = alf(I);

% Compute the center
cent = alf_SV'*SV;

% Distance to center of the sphere (ignoring the offset):
K_SV = computeKernelMatrix(ker,SV,SV);

Dx = - 2*sum( (ones(size(I,1),1)*alf_SV').*K_SV, 2);
% 

% Set all nonl-support-vector alpha to 0
% J = abs(alf)<1e-8;
% alf(J) = 0.0;

% Compute the offset 
offs = 1 + sum(sum((alf_SV *alf_SV').*computeKernelMatrix(ker,SV,SV)));
% Compute the threshold
threshold = offs+mean(Dx);

% Store the results
model.ker = ker;
model.a = alf_SV;
model.threshold = threshold;
model.sv = SV;
model.offs = offs;
model.I = I;
model.center = cent;

end