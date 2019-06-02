% DESCRIPTION
% Test for the new samples
%
%    d = svdd_test(model,y)
%
% INPUT
%   mdoel         SVDD hypersphere
%   y             New samples (vector or matrix)
%
% OUTPUT
%   d              Distance from the samles to the center of hypersphere
%
% Created by Kepeng Qiu on Jun 2, 2019.
%-------------------------------------------------------------%

function d = svdd_test(model,Y)

% Compute the kernel matrix
K = computeKM(model.ker,Y,model.X);
% the 1st term
term1 = computeKM(model.ker,Y,Y);
% the 2nd term
% term2 = -2*K*model.alf;
term2 = repmat(-2*K*model.alf,1,size(Y,1));
% the 3rd term
term3 = model.term3;
% distance
d = diag(term1+term2+term3);

end