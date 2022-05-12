classdef BaseKernel < handle
    %{
        Computation of kernel function matrix.

        Email: iqiukp@outlook.com
        -------------------------------------------------------------
        
        Version 1.0, 13-MAY-2022
            -- First release.
        -------------------------------------------------------------

            INPUT
        X         data (n*d)
        Y         data (m*d)

        OUTPUT
        K         kernel matrix (n*m)



        type   -
        
        linear      :  k(x,y) = x'*y
        polynomial  :  k(x,y) = (γ*x'*y+c)^d
        gaussian    :  k(x,y) = exp(-γ*||x-y||^2)
        sigmoid     :  k(x,y) = tanh(γ*x'*y+c)
        laplacian   :  k(x,y) = exp(-γ*||x-y||)
    
    
        degree -  d
        offset -  c
        gamma  -  γ
        -------------------------------------------------------------

        BSD 3-Clause License
        Copyright (c) 2022, Kepeng Qiu
        All rights reserved.
    %}

    properties
        type = 'gaussian' % 
        offset = 0
        gamma = 0.1
        degree = 2
    end
    
    methods
        % create an object
        function obj = BaseKernel(varargin)
            inputValue = varargin;
            numParameter = size(inputValue, 2)/2;
            supportedKernelFunc = {'linear', 'gaussian', 'polynomial', 'sigmoid', 'laplacian'};
            for n = 1:numParameter
                parameter = inputValue{(n-1)*2+1};
                value = inputValue{(n-1)*2+2};
                if strcmp(parameter, 'type')
                    if ~any(strcmp(value, supportedKernelFunc))
                    errorText = sprintf([
                        'Unsupported kernel function.\n',...
                        'Use one of these kernel functions:\n', ...
                        'linear, gaussian, polynomial, sigmoid, laplacian.']); 
                    error(errorText)
                    end
                end
                obj.(parameter) = value;
            end
        end
        
        % compute kernel function matrix
        function K = computeMatrix(obj, x, y)
            K = zeros(size(x, 1), size(y, 1));
            switch obj.type
                case 'linear' % linear kernel function
                    K = x*y';
                case 'gaussian' % gaussian kernel function
                    K = exp(-obj.gamma*pdist2(x, y, 'squaredeuclidean'));
                case 'polynomial' % polynomial kernel function
                    K = (obj.gamma*x*y'+obj.offset).^double(obj.degree);
                case 'sigmoid' % sigmoid kernel function
                    K = tanh(obj.gamma*x*y'+obj.offset);
                case 'laplacian' % laplacian kernel function
                    K = exp(-obj.gamma*pdist2(x, y, 'cityblock'));
            end
        end
    end
end
