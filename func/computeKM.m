% DESCRIPTION
% Compute Kernel Matrix
%
%       K = computeKM(ker,x,y)
%
% INPUT
%   ker          kernel function parameters
%   x            samples (N*d)
%                N: number of samples
%                d: number of features
%   y            samples (M*d)
%                M: number of samples
%                d: number of features
%
% OUTPUT
%   K            Kernel Matrix(N*M)
%
% use of 'ker'
%   type   -  linear :  k(x,y) = x'*y
%             poly   :  k(x,y) = (x'*y+c)^d
%             gauss  :  k(x,y) = exp(-(norm(x-y)/s)^2)
%             tanh   :  k(x,y) = tanh(g*x'*y+c)
%             exp    :  k(x,y) = exp(-(norm(x-y))/s^2)
%             lapl   :  k(x,y) = exp(-(norm(x-y))/s)
%   degree -  d
%   offset -  c
%   width  -  s
%   gamma  -  g
%
% ker = struct('type','linear','offset',c);
% ker = struct('type','ploy','degree',d,'offset',c);
% ker = struct('type','gauss','width',s);
% ker = struct('type','tanh','gamma',g,'offset',c);
% ker = struct('type','exp','width',s);
% ker = struct('type','lapl','width',s);
%
% Created by Kepeng Qiu on May 24, 2019.
%-------------------------------------------------------------%

function K = computeKM(ker,x,y)
ker_names = fieldnames(ker);
switch ker.type
    % linear kernel function
    case 'linear'
        [offset_exist,~] = ismember('offset', ker_names);
        if ~offset_exist
            c = 0; % default
        else
            c = ker.offset;
        end
        K = x*y'+c;
        
        % polynomial kernel function
    case 'ploy'
        [offset_exist,~] = ismember('offset', ker_names);
        if ~offset_exist
            c = 0; % default
        else
            c = ker.offset;
        end
        [degree_exist,~] = ismember('degree', ker_names);
        if ~degree_exist
            d = 2; % default
        else
            d = ker.degree;
        end
        K = (x*y'+c).^d;
        
        % gaussian kernel function
    case 'gauss'
        [width_exist,~] = ismember('width', ker_names);
        if ~width_exist
            s = 2; % default
        else
            s = ker.width;
        end
        sx = sum(x.^2,2);
        sy = sum(y.^2,2);
        K = exp((bsxfun(@minus,bsxfun(@minus,2*x*y',sx),sy'))/s^2);
        
        % sigmoid kernel function
    case 'tanh'
        [gamma_exist,~] = ismember('gamma', ker_names);
        if ~gamma_exist
            g = 0; % default
        else
            g = ker.gamma;
        end
        [offset_exist,~] = ismember('offset', ker_names);
        if ~offset_exist
            c = 0; % default
        else
            c = ker.offset;
        end
        K = tanh(g*x*y'+c);
        
        % exponential kernel function
    case 'exp'
        [width_exist,~] = ismember('width', ker_names);
        if ~width_exist
            s = 2; % default
        else
            s = ker.width;
        end
        
        sx = sum(x.^2,2);
        sy = sum(y.^2,2);
        K = exp(-sqrt(-(bsxfun(@minus,bsxfun(@minus,2*x*y',sx),sy')))/s^2);
        
        % laplacian kernel function
    case 'lapl'
        [width_exist,~] = ismember('width', ker_names);
        if ~width_exist
            s = 2; % default
        else
            s = ker.width;
        end
        sx = sum(x.^2,2);
        sy = sum(y.^2,2);
        K = exp(-sqrt(-(bsxfun(@minus,bsxfun(@minus,2*x*y',sx),sy')))/s);
        
    otherwise
        K = 0;
end
end