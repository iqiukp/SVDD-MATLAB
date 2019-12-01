classdef SvddFunction < handle
%{ 
    CLASS DESCRIPTION

 
-------------------------------------------------------------%
%} 
    methods(Static)
        function checkResult = checkInput(inputValue)
    
            nParameter = numel(inputValue)/2;
            if rem(nParameter, 1)
                error('Parameters to should be pairs.')
            end
            
            % default parameter setting
            checkResult.positiveCost = 0.1;
            checkResult.negativeCost = 1;
            checkResult.svddType = 'svdd';
            checkResult.kernel = Kernel('type', 'gauss', 'width', 2);
            checkResult.option = struct('display', 'on');
            
            for iParameter = 1:nParameter
                parameter = inputValue{(iParameter-1)*2+1};
                value	= inputValue{(iParameter-1)*2+2};
                checkResult.(parameter) = value;
            end
        end
            
        % get the type of label
        function labelType = getLabelType(label)
            if ~any(label == 1)  || ~any(label == -1)
                labelType = 'single';
            else
                labelType = 'hybrid';
            end
        end
    end
end

