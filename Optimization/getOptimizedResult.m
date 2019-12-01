function SVDD = getOptimizedResult(optimization, parameterValue)
    %{ 
        DESCRIPTION

            get the optimized result

              SVDD = getOptimizedResult(optimization, parameterValue)

        INPUT
          optimization         setting of the optimization problem
          parameterValue       optimized value of parameter

        OUTPUT
          SVDD                 optimized SVDD object

        Created on 1st December 2019 by Kepeng Qiu.
        -------------------------------------------------------------%
    %} 

    optimization.model.option.display = 'on';
    nParameter = size(parameterValue, 2);
    optimization = setParameterValue(optimization, parameterValue);
    SVDD = optimization.model;
    
    % display
    if strcmp(optimization.option.display, 'on')
        fprintf('\n')
        fprintf('*** Parameter optimization finished ***\n')
        for i = 1:nParameter
            string = ['best ', optimization.parameterName{1, i}, ' = %.4f \n'];
            fprintf(string, parameterValue(1, i));
        end
        fprintf('\n')
    end
end