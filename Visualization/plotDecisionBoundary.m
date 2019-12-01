function plotDecisionBoundary(SVDD, model, data, label)
    %{ 
    % DESCRIPTION
    Visualize decision boundaries of SVDD

          plotDecisionBoundary(SVDD, model, trainData, trainLabel)

        INPUT
          SVDD                SVDD object
          model               SVDD model
          data                training data
          label               training label    

    Created on 1st December 2019, by Kepeng Qiu.
    -------------------------------------------------------------%
    %} 
    
    %%
    [~, dimensionality] = size(data);
    if dimensionality ~= 2
        error('Visualization of decision boundary only supports for 2D data.')
    end
    [distance, X1, X2] = computeGridScore(SVDD, model, data);
    
    %% figure setting
   
    % axis settings
    t_gca = 10;  % font size
    % t_font = 'Helvetica'; % font type
    t_font = 'Arial'; % font type
    % legend setting
    t_legend = t_gca*0.9;
    % label setting
    t_label = t_gca*1.1;
    % size of scatter
    scatterSize = 36;
    % line width
    l_width = 1.2;

    %% contour of grid scores
    f1 = figure;
    set(f1, 'unit', 'centimeters', 'position', [0 0 12 12]);
    [~, ax1] = contourf(X1, X2, distance, 'ShowText', 'on');
    colormap(jet);
    ax1.LineWidth = 1;
    
    titleString = ['Contour of distance ', '(', SVDD.kernel.type, ')'];
    title(titleString,...
          'FontSize', t_label,...
          'FontWeight', 'normal',...
          'FontName', t_font)
      
    legend('Distance',...
           'FontSize', t_legend,...
           'FontWeight', 'normal',...
           'FontName', t_font)
    set(gca, 'linewidth', l_width, 'fontsize', t_label, 'fontname', t_font )

    %% training data and decision boundary  
    f2 = figure;
    set(f2, 'unit', 'centimeters', 'position', [0 0 12 12]);
    [~, ax2] = contourf(X1, X2, distance, [model.radius, model.radius]);
    cmap = [1, 1, 1]; 
    colormap(gca(), cmap);
    ax2.LineWidth = 2;
    ax2.LineColor = [125, 45, 141]/255;  
    hold on
    
    labelTypeFlag = 1;
    switch SVDD.labelType
        case 'single'
            labelTypeFlag = 1;
            % training data
            scatter(data(:, 1), data(:, 2),...
                scatterSize, 'o',...
                'MarkerEdgeColor', 'k',...
                'MarkerFaceColor', [186, 40, 53]/255);
            
        case 'hybrid'
            labelTypeFlag = -1;
            scatter(data(label == 1, 1), data(label == 1, 2),...
                scatterSize, 'o',...
                'MarkerEdgeColor', 'k',...
                'MarkerFaceColor', [186, 40, 53]/255);
            
            scatter(data(label == -1, 1), data(label == -1, 2),...
                scatterSize, 's',...
                'MarkerEdgeColor', 'k',...
                'MarkerFaceColor', [186, 40, 53]/255);
    end

    % support vectors (on)
    SvOn = data(model.SvIndices, :);
    scatter(SvOn(:, 1), SvOn(:, 2), scatterSize,...
            'MarkerEdgeColor', 'k',...
            'MarkerFaceColor', [29, 191, 151]/255);

    % support vectors (out)
    SvOutFlag = 0;
    if ~isempty(model.SvIndicesOut)
        SvOutFlag = 1;
        SvOut = data(model.SvIndicesOut, :);
        scatter(SvOut(:, 1), SvOut(:, 2), scatterSize,...
            'MarkerEdgeColor', 'k',...
            'MarkerFaceColor', [40, 132, 252]/255);
    end
    
    if labelTypeFlag == 1 && SvOutFlag == 0
        legendString = {'Decision boundary',...
                        'Training data (+)',...
                        'Support vector (on)'};
    end
    
    if labelTypeFlag == 1 && SvOutFlag == 1
        legendString = {'Decision boundary',...
                        'Training data (+)',...
                        'Support vector (on)',...
                        'Support vector (out)'};
    end

    if labelTypeFlag == -1 && SvOutFlag == 0
        legendString = {'Decision boundary',...
                        'Training data (+)',...
                        'Training data (-)',...
                        'Support vector (on)'};
    end
    
    if labelTypeFlag == -1 && SvOutFlag == 1
        legendString = {'Decision boundary',...
                        'Training data (+)',...
                        'Training data (-)',...
                        'Support vector (on)',...
                        'Support vector (out)'};
    end
    
    try
    legend(legendString,...
           'FontSize', t_legend,...
           'FontWeight', 'normal',...
           'FontName', t_font,...
           'Location', 'northwest',...
           'NumColumns', 2)
    catch
    legend(legendString,...
           'FontSize', t_legend,...
           'FontWeight', 'normal',...
           'FontName', t_font,...
           'Location', 'northwest')
    end
     
       
    titleString = ['Training data and decision boundary ', '(', SVDD.kernel.type, ')'];
    title(titleString,...
          'FontSize', t_label,...
          'FontWeight', 'normal',...
          'FontName', t_font)
    set(gca, 'linewidth', l_width, 'fontsize', t_label, 'fontname', t_font )
    hold off

end
