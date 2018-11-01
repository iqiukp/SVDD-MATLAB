% DESCRIPTION
% Compute Kernel Matrix
% x: iuput samples (n1¡Ád)
% y: iuput samples (n2¡Ád)
% n1,n2: number of iuput samples
% d: characteristic dimension of the samples
% ker: kernel function parameters
% the following fields:
%   type   - linear :  k(x,y) = x'*y
%            poly   :  k(x,y) = (x'*y+c)^d
%            gauss  :  k(x,y) = exp(-0.5*(norm(x-y)/s)^2)
%            tanh   :  k(x,y) = tanh(g*x'*y+c)
%   degree - Degree d of polynomial kernel (positive scalar).
%   offset - Offset c of polynomial and tanh kernel (scalar, negative for tanh).
%   width  - Width s of Gauss kernel (positive scalar).
%   gamma  - Slope g of the tanh kernel (positive scalar).
%
% ker = struct('type','linear');
% ker = struct('type','ploy','degree',d,'offset',c);
% ker = struct('type','gauss','width',s);
% ker = struct('type','tanh','gamma',g,'offset',c);
%
% K: kernelMatrix (n1¡Án2)

%-------------------------------------------------------------%
function [K] = computeKernelMatrix(ker,x,y)
switch ker.type
    case 'linear'
        K = x*y';
        
    case 'ploy'
        d = ker.degree;
        c = ker.offset;
        K = (x'*y+c).^d;
        
    case 'gauss'
        s = ker.width;
        sx = sum(x.^2,2);
        sy = sum(y.^2,2);
        K = exp((bsxfun(@minus,bsxfun(@minus,2*x*y',sx),sy'))/s^2);
    case 'tanh'
        g = ker.gamma;
        c = ker.offset;
        K = tanh(g*x'*y+c);
    otherwise
        K = 0;
end
end