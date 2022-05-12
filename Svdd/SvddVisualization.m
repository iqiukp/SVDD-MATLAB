classdef SvddVisualization < handle
    %{
        Visualization of trained SVDD model and test results.

        Version 1.1, 13-MAY-2022
        Email: iqiukp@outlook.com

        ------------------------------------------------------------
        
        BSD 3-Clause License
        Copyright (c) 2022, Kepeng Qiu
        All rights reserved.
    %}

    properties (Constant)
        positionForOne = [300 150 640 480]
        positionForTwo = [300 150 1200 500]
        colorDistance = [125, 45, 141]/255
        colorRadius = [213, 81, 36]/255
        colorBoundary = [214, 39, 40]/255
        faceColorBoundary = [155, 176, 175]/255
        faceAlphaBoundary = 0.6
        lineWidthDistance = 2
        lineWidthBox = 1.1
        lineWidthBoundary = 3.5
        lineWidthROC = 3
        radioExpansion = 0.3 % radio of expansion (0<r<1)
        radioZData = 5
        numGrids = 30
        scatterSize = 36
        viewAngle = [-47 35]
        markerFaceColorPositive = [31, 119, 180]/255
        markerFaceColorNegetive = [148, 103, 189]/255
        markerFaceColorSupport = [44, 160, 44]/255
        tickDirection = 'in'
    end
    
    methods
        function distance(obj, svdd, results)
            figure
            set(gcf, 'position', obj.positionForOne)
            hold on
            plot(svdd.radius*ones(results.numSamples, 1),...
                'color', obj.colorRadius,...
                'LineStyle', '-', 'LineWidth', obj.lineWidthDistance)
            plot(results.distance, 'color', obj.colorDistance,...
                'LineStyle', '-', 'LineWidth', obj.lineWidthDistance)
            legend({'Radius', 'Distance'})
            xlabel('Samples')
            ylabel('Distance')
            set(gca, 'LineWidth', obj.lineWidthBox, 'Ygrid', 'on', 'TickDir', obj.tickDirection)
            box(gca, 'on');
        end
        
        function boundary(obj, svdd)
            if svdd.numFeatures < 2 || svdd.numFeatures > 3
                error('Boundary visualization is only supported for 2D or 3D data.')
            end
            % compute the range of grid
            x_range = zeros(obj.numGrids, svdd.numFeatures);
            for i = 1:svdd.numFeatures
                x = svdd.data(:, i);
                xlim_1 = min(x)-(max(x)-min(x))*obj.radioExpansion;
                xlim_2 = max(x)+(max(x)-min(x))*obj.radioExpansion;
                x_range(:, i) = linspace(xlim_1, xlim_2, obj.numGrids);
            end
            display_ = svdd.display;
            crossValidation_ = svdd.crossValidation;
            svdd.display = 'off';
            svdd.crossValidation.switch = 'off';
            % display boundary
            switch svdd.numFeatures
                % boundary for 2D data
                case 2
                    [X1, X2] = meshgrid(x_range(:, 1), x_range(:, 2));
                    X_ = [reshape(X1, [obj.numGrids*obj.numGrids, 1]),...
                        reshape(X2, [obj.numGrids*obj.numGrids, 1])];
                    XX_ = mat2cell(X_, obj.numGrids*ones(obj.numGrids, 1), 2);
                    distance_ = cell(obj.numGrids, 1);
                    for i = 1:obj.numGrids
                        svdd.evaluationMode = 'train';
                        results_ = svdd.test(XX_{i}, ones(obj.numGrids, 1));
                        svdd.evaluationMode = 'test';
                        distance_{i,1} = results_.distance;
                    end
                    distance = cell2mat(distance_);
                    dist_ = reshape(distance, [obj.numGrids, obj.numGrids]);
                    % contour
                    figure
                    set(gcf, 'position', obj.positionForTwo)
                    subplot1 = subplot(1, 2, 1);
                    contourf(X1, X2, dist_);
                    colormap(parula);
                    box(subplot1, 'on');
                    grid(subplot1, 'on');
                    set(subplot1, 'LineWidth', obj.lineWidthBox, 'TickDir', obj.tickDirection);
                    axis tight
                    title(['Contour of distance ', '(', svdd.kernelFunc.type, ')'])
                    
                    subplot2 = subplot(1, 2, 2);
                    [~, ax2] = contourf(X1, X2, dist_, [svdd.radius, svdd.radius]);
                    cmap = [1, 1, 1];
                    colormap(gca, cmap);
                    ax2.LineWidth = obj.lineWidthBoundary;
                    ax2.LineColor = obj.colorBoundary;
                    %
                    svdd.boundaryHandle.XData = X1;
                    svdd.boundaryHandle.YData = X2;
                    svdd.boundaryHandle.ZData = dist_;
                    hold on
                    switch svdd.dataType
                        case 'single'
                            legendFlag_ = 1;
                            scatter(svdd.data(:, 1), svdd.data(:, 2),...
                                obj.scatterSize, 'o',...
                                'MarkerEdgeColor', 'k',...
                                'MarkerFaceColor', obj.markerFaceColorPositive);
                            
                        case 'hybrid'
                            legendFlag_ = -1;
                            scatter(svdd.data(svdd.label == 1, 1), svdd.data(svdd.label == 1, 2),...
                                obj.scatterSize, 'o',...
                                'MarkerEdgeColor', 'k',...
                                'MarkerFaceColor', obj.markerFaceColorPositive)
                            
                            scatter(svdd.data(svdd.label == -1, 1), svdd.data(svdd.label == -1, 2),...
                                obj.scatterSize, 's',...
                                'MarkerEdgeColor', 'k',...
                                'MarkerFaceColor', obj.markerFaceColorNegetive)
                    end
                    % support vectors
                    scatter(svdd.supportVectors(:, 1), svdd.supportVectors(:, 2), obj.scatterSize,...
                        'MarkerEdgeColor', 'k',...
                        'MarkerFaceColor', obj.markerFaceColorSupport)
                    box(subplot2, 'on');
                    grid(subplot2, 'on');
                    set(subplot2, 'LineWidth', obj.lineWidthBox, 'TickDir', obj.tickDirection);
                    
                    % boundary for 3D data
                case 3
                    [X1, X2, X3] = meshgrid(x_range(:, 1), x_range(:, 2), x_range(:, 3));
%                     z_min = obj.radioZData*min(x_range(:, 3));
%                     z_max = obj.radioZData*max(x_range(:, 3));
                    X_ = [reshape(X1, [obj.numGrids*obj.numGrids*obj.numGrids, 1]), ...
                        reshape(X2, [obj.numGrids*obj.numGrids*obj.numGrids, 1]),...
                        reshape(X3, [obj.numGrids*obj.numGrids*obj.numGrids, 1])];
                    XX_ = mat2cell(X_, obj.numGrids*obj.numGrids*ones(obj.numGrids, 1), 3);
                    distance_ = cell(obj.numGrids, 1);
                    for i = 1:obj.numGrids
                        svdd.evaluationMode = 'train';
                        results_ = svdd.test(XX_{i}, ones(obj.numGrids*obj.numGrids, 1));
                        svdd.evaluationMode = 'test';
                        distance_{i, 1} = results_.distance;
                    end
                    distance = cell2mat(distance_);
                    dist_ = reshape(distance, [obj.numGrids, obj.numGrids, obj.numGrids]);
                    
                    % contour
                    figure
                    set(gcf, 'position', obj.positionForTwo)
                    hold on
                    subplot1 = subplot(1, 2, 1);
                    levelList = linspace(min(min(min(dist_))), max(max(max(dist_))), 10);
                    for i = 1:length(levelList)
                        level = levelList(i);
                        p = patch(isosurface(X1, X2, X3, dist_, level));
                        isonormals(X1, X2, X3, dist_, p)
                        p.FaceVertexCData = level;
                        p.FaceColor = 'flat';
                        p.EdgeColor = 'none';
                        p.FaceAlpha = obj.faceAlphaBoundary;
                    end
                    % save boundary handle
                    svdd.boundaryHandle.levelList = levelList;
                    svdd.boundaryHandle.XData = X1;
                    svdd.boundaryHandle.YData = X2;
                    svdd.boundaryHandle.ZData = X3;
                    svdd.boundaryHandle.VData = dist_;
                    % setting
%                     zlim(subplot1, [z_min z_max]);
                    view(subplot1, obj.viewAngle);
                    box(subplot1, 'on');
                    grid(subplot1, 'on');
                    set(subplot1, 'LineWidth', obj.lineWidthBox, 'TickDir', obj.tickDirection);
                    title(['Contour of distance ', '(', svdd.kernelFunc.type, ')'])
                    %
                    subplot2 = subplot(1, 2, 2);
                    p = patch(isosurface(X1, X2, X3, dist_, svdd.radius));
                    isonormals(X1, X2, X3, dist_, p)
                    p.FaceColor = obj.faceColorBoundary;
                    p.EdgeColor = 'none';
                    p.FaceAlpha = obj.faceAlphaBoundary;
                    
                    hold on
                    switch svdd.dataType
                        case 'single'
                            legendFlag_ = 1;
                            scatter3(svdd.data(:, 1), svdd.data(:, 2), svdd.data(:, 3),...
                                obj.scatterSize, 'o',...
                                'MarkerEdgeColor', 'k',...
                                'MarkerFaceColor', obj.markerFaceColorPositive);
                            
                        case 'hybrid'
                            legendFlag_ = -1;
                            scatter3(svdd.data(svdd.label == 1, 1), svdd.data(svdd.label == 1, 2),...
                                svdd.data(svdd.label == 1, 3),...
                                obj.scatterSize, 'o',...
                                'MarkerEdgeColor', 'k',...
                                'MarkerFaceColor', obj.markerFaceColorPositive)
                            
                            scatter3(svdd.data(svdd.label == -1, 1), svdd.data(svdd.label == -1, 2),...
                                svdd.data(svdd.label == -1, 3),...
                                obj.scatterSize, 's',...
                                'MarkerEdgeColor', 'k',...
                                'MarkerFaceColor', obj.markerFaceColorNegetive)
                    end
                    % support vectors
                    scatter3(svdd.supportVectors(:, 1), svdd.supportVectors(:, 2),...
                        svdd.supportVectors(:, 3), obj.scatterSize,...
                        'MarkerEdgeColor', 'k',...
                        'MarkerFaceColor', obj.markerFaceColorSupport);
%                     zlim(subplot2, [z_min z_max]);
                    view(subplot2, obj.viewAngle);
                    box(subplot2, 'on');
                    grid(subplot2, 'on');
                    set(subplot2, 'LineWidth', obj.lineWidthBox, 'TickDir', obj.tickDirection);
                    title('Decision boundary')
            end
            
            svdd.display = display_;
            svdd.crossValidation.switch = crossValidation_;
            
            if legendFlag_ == 1
                legendString = {'Decision boundary', 'Training data', 'Support vectors'};
            else
                legendString = {'Decision boundary', 'Training data (+)',...
                                'Training data (-)', 'Support vectors'};
            end
            try
                legend(legendString, 'Location', 'northwest', 'NumColumns', 2)
            catch
                legend(legendString, 'Location', 'northwest')
            end
        end
        
        function ROC(obj, results)
            % plot the ROC curve
            if strcmp(results.dataType, 'single')
                error('ROC visualization is only supported for dataset with two classes.')
            end
            figure
            set(gcf, 'position', obj.positionForOne)
            plot(results.performance.FPR, results.performance.TPR,...
                'color', obj.colorBoundary,...
                'LineStyle', '-', 'LineWidth', obj.lineWidthROC)
            xlabel('False positive rate (FPR)')
            ylabel('True positive rate (TPR)')
            set(gca,'LineWidth', obj.lineWidthBox, 'XGrid', 'on', 'YGrid','on',...
                'TickDir', obj.tickDirection);
            box(gca, 'on');
            titleStr = ['Area under the curve (AUC) = ', sprintf( '%.4f', results.performance.AUC)];
            title(titleStr)
        end
        
        function testDataWithBoundary(obj, svdd, results)
            if svdd.numFeatures < 2 || svdd.numFeatures > 3
                error('Boundary visualization is only supported for 2D or 3D data.')
            end
            % compute the range of grid
            x_range = zeros(obj.numGrids, svdd.numFeatures);
            for i = 1:svdd.numFeatures
                x = results.data(:, i);
                xlim_1 = min(x)-(max(x)-min(x))*obj.radioExpansion;
                xlim_2 = max(x)+(max(x)-min(x))*obj.radioExpansion;
                x_range(:, i) = linspace(xlim_1, xlim_2, obj.numGrids);
            end
            
            figure
            set(gcf, 'position', obj.positionForOne)
            switch svdd.numFeatures
                % boundary for 2D data
                case 2
                    [~, ax] = contourf(svdd.boundaryHandle.XData, svdd.boundaryHandle.YData,...
                        svdd.boundaryHandle.ZData, [svdd.radius, svdd.radius]);
                    cmap = [1, 1, 1];
                    colormap(gca, cmap);
                    ax.LineWidth = obj.lineWidthBoundary;
                    ax.LineColor = obj.colorBoundary;
                    hold on
                    switch results.dataType
                        case 'single'
                            legendFlag_ = 1;
                            scatter(results.data(:, 1), results.data(:, 2),...
                                obj.scatterSize, 'o',...
                                'MarkerEdgeColor', 'k',...
                                'MarkerFaceColor', obj.markerFaceColorPositive);
                            
                        case 'hybrid'
                            legendFlag_ = -1;
                            scatter(results.data(results.label == 1, 1), results.data(results.label == 1, 2),...
                                obj.scatterSize, 'o',...
                                'MarkerEdgeColor', 'k',...
                                'MarkerFaceColor', obj.markerFaceColorPositive)
                            
                            scatter(results.data(results.label == -1, 1), results.data(results.label == -1, 2),...
                                obj.scatterSize, 's',...
                                'MarkerEdgeColor', 'k',...
                                'MarkerFaceColor', obj.markerFaceColorNegetive)
                    end
                    % boundary for 3D data
                case 3
                    p = patch(isosurface(svdd.boundaryHandle.XData, svdd.boundaryHandle.YData,...
                        svdd.boundaryHandle.ZData, svdd.boundaryHandle.VData, svdd.radius));
                    isonormals(svdd.boundaryHandle.XData, svdd.boundaryHandle.YData,...
                        svdd.boundaryHandle.ZData, svdd.boundaryHandle.VData, p)
                    p.FaceColor = obj.faceColorBoundary;
                    p.EdgeColor = 'none';
                    p.FaceAlpha = obj.faceAlphaBoundary;
                    
                    hold on
                    switch results.dataType
                        case 'single'
                            legendFlag_ = 1;
                            scatter3(results.data(:, 1), results.data(:, 2), results.data(:, 3),...
                                obj.scatterSize, 'o',...
                                'MarkerEdgeColor', 'k',...
                                'MarkerFaceColor', obj.markerFaceColorPositive);
                            
                        case 'hybrid'
                            legendFlag_ = -1;
                            scatter3(results.data(results.label == 1, 1), results.data(results.label == 1, 2),...
                                results.data(results.label == 1, 3),...
                                obj.scatterSize, 'o',...
                                'MarkerEdgeColor', 'k',...
                                'MarkerFaceColor', obj.markerFaceColorPositive)
                            
                            scatter3(results.data(results.label == -1, 1), results.data(results.label == -1, 2),...
                                results.data(results.label == -1, 3),...
                                obj.scatterSize, 's',...
                                'MarkerEdgeColor', 'k',...
                                'MarkerFaceColor', obj.markerFaceColorNegetive)
                    end
                    % setting
%                     z_min = obj.radioZData*min(x_range(:, 3));
%                     z_max = obj.radioZData*max(x_range(:, 3));
%                     zlim(gca, [z_min z_max]);
                    view(gca, obj.viewAngle);
            end
            
            if legendFlag_ == 1
                legendString = {'Decision boundary', 'Test data'};
            else
                legendString = {'Decision boundary', 'Test data (+)', 'Test data (-)'};
            end
            try
                legend(legendString, 'Location', 'northwest', 'NumColumns', 3)
            catch
                legend(legendString, 'Location', 'northwest')
            end
            set(gca, 'LineWidth', obj.lineWidthBox, 'Xgrid', 'on', 'Ygrid', 'on',...
                'Zgrid', 'on', 'TickDir', obj.tickDirection)
            box(gca, 'on');
            title('Decision boundary and test data')
        end
    end
end