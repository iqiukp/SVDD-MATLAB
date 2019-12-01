classdef SvddTrainBase < handle
%{ 
    CLASS DESCRIPTION

-------------------------------------------------------------%
%} 
    methods(Abstract)
        train(~)
    end
    
    methods(Static)
        function trainType = setFunction(value)
            switch value
                case 'svdd'
                    trainType = SvddTrain;
                % case
            end
        end   
    end
end
