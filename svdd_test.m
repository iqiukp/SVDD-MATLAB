% DESCRIPTION
% Test for the new samples
%
%    [D] = SVDD_TEST(MODEL,Y)
%
% INPUT
%   MODEL         SVDD hypersphere
%   Y             New samples (vector or matrix)
%
% OUTPUT
%   D       Distance from the samles to the center of hypersphere
% Created on 1st November, 2018, by Kepeng Qiu.

function d = svdd_test(model,y)

% Compute kernel matrix
K = computeKernelMatrix(model.ker,y,model.sv);

% Compute the distance
Dx = - 2*sum( (ones(size(y,1),1)*model.a').*K, 2);
d = model.offs+Dx;

end