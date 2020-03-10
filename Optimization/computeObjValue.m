function objValue = computeObjValue(parameter)
    %{ 
        DESCRIPTION

            compute the value of objective function 

              objValue = computeObjValue(parameter)

        INPUT
          parameter            SVDD parameter and kernel parameter

        OUTPUT
          objValue             value of objective function

        Created on 1st December 2019 by Kepeng Qiu.
        -------------------------------------------------------------%
    %} 
    
    obj = evalin('base', 'optimization');
    data = evalin('base', 'trainData');
    label = evalin('base', 'trainLabel');
    tmpLabelType = SvddFunction.getLabelType(label);
    nParameter = size(parameter, 2);
    if ~ismember(fieldnames(obj), 'parameterName')
        error('Please enter the names of the parameters that need to be optimized.')
    end
    
    if numel(obj.parameterName) ~= nParameter
        error('Please enter the correct number of parameter names.')
    end
    
    obj = setParameterValue(obj, parameter);
    obj.model.option.display = 'off';
    switch obj.option.type
        case 'crossvalidation'
            %  k-fold cross-validation
            [isKfoldsExist, ~] = ismember('Kfolds', fieldnames(obj.option));
            if isKfoldsExist
                nKfolds = obj.option.Kfolds;
                tmp = data;
                tmpLabel = label;
                m = size(tmp ,1);
                indices = crossvalind('Kfold', m, nKfolds);
                accuracyTemp = [];
                count = 1;
                for i = 1:nKfolds
                    test=(indices==i);
                    testData = tmp(test, :);
                    testLabel = tmpLabel(test, :);
                    data = tmp(~test, :);
                    label = tmpLabel(~test, :);
                    cvLabelType = SvddFunction.getLabelType(label);
                    if cvLabelType ~= tmpLabelType
                        continue;
                    end

                    model = obj.model.train(data, label);
                    result = obj.model.test(model,testData, testLabel);
                    accuracyTemp(count, 1) = result.accuracy;
                    count = count+1;
                end
                objValue = 1-mean(accuracyTemp);
            else
                error('Please enter the value of Kfolds.')
            end

        case 'normal'
            model = obj.model.train(data, label);
            result = obj.model.test(model, data, label);
            objValue = 1-result.accuracy;
    end
end

