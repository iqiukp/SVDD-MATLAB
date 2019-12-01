function [trainData, testData] = standardize(trainData, testData)
    %{ 
        DESCRIPTION

            standardize the training data and testing data

              [trainData, testData] = standardize(trainData, testData)

        INPUT
          trainData            training data (N*d)
                               N: number of samples
                               d: number of features
          testData             testing data (N*d)
                               N: number of samples
                               d: number of features

        OUTPUT
          trainData            standardized training data
          testData             standardized testing data (N*d)


        Created on 1st December 2019 by Kepeng Qiu.
        -------------------------------------------------------------%
    %} 

    % standardize trainData
    X_mu = mean(trainData);
    X_std = std(trainData);
    trainData = zscore(trainData);

    % standardize testData using the mean and standard deviation of trainData
    try
        testData = bsxfun(@rdivide,bsxfun(@minus,testData,X_mu),X_std);
    catch
        mu_array = repmat( X_mu, size(testData,1), 1);
        st_array = repmat( X_std, size(testData,1), 1);
        testData = (testData-mu_array)./st_array;
    end
end