function obj = setParameterName(obj)
    %{ 
        DESCRIPTION
            set the parameter names
                obj = setParameterName(obj)

        -------------------------------------------------------------%
    %} 

    tmp = fieldnames(obj.model.kernel.parameter);
    switch obj.model.labelType
        case 'single'
            obj.parameterName = [{'positiveCost'}, tmp(:)'];
        case 'hybrid'
            obj.parameterName = [{'positiveCost', 'negativeCost'}, tmp(:)'];
    end
end