function obj = setParameterValue(obj, para)
    %{ 
        DESCRIPTION
            set the parameter value
                obj = setParameterValue(obj, para)

        -------------------------------------------------------------%
    %} 

    nParameter = numel(obj.parameterName);
    for indexParameter = 1:nParameter
        parameterName = obj.parameterName{1, indexParameter};
        
        if strcmp(parameterName, 'positiveCost') ||...
                strcmp(parameterName, 'negativeCost')
            obj.model.(parameterName) =...
                para(1, strcmp(parameterName, obj.parameterName));
        else
            obj.model.kernel.parameter.(parameterName) =...
                para(1,strcmp(parameterName, obj.parameterName));
        end
        
%         if strcmp(parameterName, 'degree')
%             value = obj.model.kernel.parameter.degree;
%             obj.model.kernel.parameter.degree = fix(value);
%         end
    end
    
    
    
end