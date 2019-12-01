function [trainData, trainLabel, testData, testLabel] = prepareData(dataName)
    %{ 
    % DESCRIPTION

    Prepare the training data and testing data

          [trainData, testData, trainLabel, testLabel] = prepareData

    INPUT
          dataName            name of dataset

    OUTPUT
          trainData           Training data
          trainLabel          Training label
          testData            Testing data
          testLabel           Testing label

    Created on 1st December 2019, by Kepeng Qiu.
    -------------------------------------------------------------%
    %} 

    switch dataName
        case 'banana'
            tmp = load ('.\data\banana.mat');
            data = tmp.banana(:, 1:2);
            index_p = (tmp.banana(:, 3) == 0);

        case 'wine'
            tmp = load ('.\data\wine.mat');
            data = tmp.wine(:, 2:14);
            index_p = (tmp.wine(:, 1) == 1);

        case 'heart_scale'
            tmp = load ('.\data\heart_scale.mat');
            data = tmp.heart_scale_inst;
            label = tmp.heart_scale_label;
            index_p = (label(:,1) == 1);

        case 'industial'
            tmp = load ('.\data\industial.mat');
            data = tmp.data;
            label = tmp.label;
            index_p = (label(:,1) == 1);

        case 'iris'
            tmp = load ('.\data\iris.mat');
            data = tmp.data;
            label = tmp.label;
            index_p = (label(:,1) == 1);
    end

    n_p = sum(index_p);
    index_n = ~index_p;
    n_n = sum(index_n);
    data_p = data(index_p, :);
    data_n = data(index_n, :);
    label_p = ones(n_p,1);
    label_n = -ones(n_n,1);



    rate_p = 0.3;
    cv_p = crossvalind('HoldOut',n_p ,rate_p);

    rate_n = 0.9;
    cv_n = crossvalind('HoldOut',n_n ,rate_n);

    trainData = [data_p(cv_p,:);data_n(cv_n,:)];
    trainLabel = [label_p(cv_p,:);label_n(cv_n,:)];

    testData = [data_p(~cv_p,:);data_n(~cv_n,:)];
    testLabel = [label_p(~cv_p,:);label_n(~cv_n,:)];

end