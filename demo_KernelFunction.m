%{
    Demonstration of computing the kernel function matrix.


        linear      :  k(x,y) = x'*y
        polynomial  :  k(x,y) = (γ*x'*y+c)^d
        gaussian    :  k(x,y) = exp(-γ*||x-y||^2)
        sigmoid     :  k(x,y) = tanh(γ*x'*y+c)
        laplacian   :  k(x,y) = exp(-γ*||x-y||)

%}

clc
close all
addpath(genpath(pwd))

% data
X = rand(30, 2);
Y = rand(20, 2);

% kernel setting
kernelObj = cell(5, 1);
kernelObj{1, 1} = BaseKernel('type', 'gaussian', ...
                             'gamma', 1);

kernelObj{2, 1} = BaseKernel('type', 'polynomial', ...
                             'degree', 2, ...
                             'gamma',  1, ...
                             'offset', 0);

kernelObj{3, 1} = BaseKernel('type', 'linear');

kernelObj{4, 1} = BaseKernel('type', 'sigmoid', ...
                             'gamma', 1, ...
                             'offset', 0);

kernelObj{5, 1} = BaseKernel('type', 'laplacian', ...
                             'gamma', 1);

% compute the kernel function matrix
kernelMatrix = cell(5, 1);
figure
set(gcf, 'position', [100, 100, 600, 400])
titleName = {'gaussian', 'polynomial', 'linear',...
             'sigmoid', 'laplacian'};
for i = 1:5
    kernelMatrix{i, 1} = kernelObj{i, 1}.computeMatrix(X, Y);
    subplot(3, 2, i)
    mesh(kernelMatrix{i, 1})
    colorbar
    colormap('parula')
    title(titleName{1, i})
end
