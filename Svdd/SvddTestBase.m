classdef SvddTestBase < handle
%{ 
    CLASS DESCRIPTION

-------------------------------------------------------------%
%} 
    methods(Abstract)
        test(~)
    end
    
    methods(Static)
        function testType = setFunction(value)
            switch value
                case 'svdd'
                    testType = SvddTest;
                % case
            end
        end   
    end
end
