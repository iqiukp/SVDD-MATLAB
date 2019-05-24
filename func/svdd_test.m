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
% Created by Kepeng Qiu on May 24, 2019.
%-------------------------------------------------------------%

function d = svdd_test(model,y)

% Compute kernel matrix
K = computeKM(model.ker,y,model.SV_value);

% Compute the distance
Dx = - 2*sum( (ones(size(y,1),1)*model.SV_alf').*K, 2);
d = model.offs+Dx;

end