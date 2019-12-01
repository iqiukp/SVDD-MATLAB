classdef SvddTrain < SvddTrainBase
    methods
        function model = train(~, obj, data, label)
        %{

        DESCRIPTION
           Train the SVDD model


              model = train(~, obj, data, label)

                INPUT
                  obj         SVDD object
                  data        training data
                  label       training label

                OUTPUT
                  model       SVDD model
            
        Created on 1st December 2019 by Kepeng Qiu.
        -------------------------------------------------------------%
            
        %}
            
            N = size(data, 1);
            K = obj.kernel.getKernelMatrix(data, data);
            [alf, objValue, iter] = computeALF(obj, K, label);
            threshold = 1e-8;
            
            % indices of support vector
            SvIndices = find(alf > threshold & alf<=obj.positiveCost(1, 1));
            
            % Lagrange coefficient
            nSVs = size(SvIndices, 1);
            SvIndicesOut = find(abs(alf-obj.positiveCost(1, 1)) <= threshold);
            SVs = data(SvIndices, :);
            SvAlf = alf(SvIndices);
            
            % compute the center: eq(7)
            center = alf'*data;
            RandSvIndices = SvIndices(1, 1);
            % the 1st term in eq(15)
            term1 = K(RandSvIndices, RandSvIndices);
            
            % the 2nd term in eq(15)
            K_tmp = label*label'.*K;
            term2 = -2*K_tmp (RandSvIndices, :)*alf;
            
            % the 3rd term in eq(15)
            term3 = sum(sum((alf *alf').*K_tmp));
            
            % radius
            radius = term1+term2+term3;
            
            % store the model
            model.data = data;
            model.label = label;
            model.labelType = obj.labelType;
            model.positiveCost = obj.positiveCost;
            model.negativeCost = obj.negativeCost;
            model.kernel = obj.kernel;
            model.svddType =  obj.svddType;
            model.SvAlf = SvAlf;
            model.radius = radius;
            model.SVs = SVs;
            model.SvIndices = SvIndices;
            model.center = center;
            model.term3 = term3;
            model.alf = alf;
            model.SvIndicesOut = SvIndicesOut;

            if strcmp(obj.option.display, 'on')
                fprintf('\n')
                fprintf('*** SVDD model training finished ***\n')
                fprintf('iter = %d \n', iter);
                fprintf('obj = %f \n', objValue)
                fprintf('nSVs = %d \n', nSVs)
                fprintf('radio of nSVs = %.2f%% \n', 100*nSVs/N)
                fprintf('\n')
            end
        end
    end
end

function [alf, objValue, iter] = computeALF(obj, K, label)

    N = size(K, 1);
    % Coefficient of Quadratic optimization
    % H: Symmetric Hessian matrix
    H = label*label'.*K;
    H = H+H';

    % f
    f = -(label.*diag(K));

    % Lower and upper bounds
    lb = zeros(N, 1);
    ub = ones(N, 1);
    switch obj.labelType
        case 'single'
            ub(label==1, 1) = obj.positiveCost;
        case 'hybrid'
            ub(label==1, 1) = obj.positiveCost;
            ub(label==-1, 1) = obj.negativeCost;
    end

    % Linear Equality Constraint
    Aeq = ones(1, N);
    beq = 1;

    % Quadratic optimize
    opt = optimset('quadprog');
    opt.Algorithm = 'interior-point-convex';
    opt.Display = 'off';
    [alf, objValue, ~, output] = quadprog(H, f, [], [], Aeq, beq, lb, ub, [], opt);
    if isempty(alf)
        warning('Value of positive cost is too small.')
    end
    
    iter = output.iterations;
end

