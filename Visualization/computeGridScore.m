function [distance, X1, X2] = computeGridScore(SVDD, model, data)
    %{ 
    DESCRIPTION
        Compute the grid scores

            [distance, X1, X2] = computeGridScore(SVDD, model, data)

        INPUT
          SVDD         SVDD object
          model        SVDD model
          data         training data


        OUTPUT
          distance     grid scores
          X1           grids
          X2           grids


    Created on 1st December 2019, by Kepeng Qiu.
    -------------------------------------------------------------%
    %} 

    % compute the range of grid 
    x1_range = computeGridRange(data(:, 1));
    x2_range = computeGridRange(data(:, 2));

    % grid 
    [X1, X2] = meshgrid(x1_range, x2_range);

    display = SVDD.option.display;
    SVDD.option.display = 'off';
    numX1 = size(X1,1);
    numX2 = size(X2,1);
    distance = zeros(numX1, numX2);
    for i = 1:numX1
        for j = 1:numX2
            tmp = [X1(i,j), X2(i,j)];        
            result = SVDD.test(model, tmp, 1);
            distance(i, j) = result.distance;
        end
    end
    SVDD.option.display = display;
end
