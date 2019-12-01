function varargout = plotROC(label, distance)
    %{
    DESCRIPTION
    Compute the Area under the curve (AUC) of SVDD

          computeAUC(label, distance)
          AUC = computeAUC(label, distance)
          [AUC, FPR] = computeAUC(label, distance)
          [AUC, FPR, TPR] = computeAUC(label, distance)

    INPUT
      label             Nomal samples (+1); abnomal samples(-1)
      distance          Distance between the sample and the center

    OUTPUT
      AUC               Area under the curve (AUC)
      FPR               False positive rate
      TPR               True positive rate

    Created on 1st December 2019, by Kepeng Qiu.
    -------------------------------------------------------------
    %}

    % number of positive samples
    n_p = sum(label == 1, 1);
    % number of negative samples
    n_n = sum(label == -1, 1);
    if ~any(label == 1)  || ~any(label == -1)
        error('Both positive and negative labels must be entered.');
    end
    [~, dis_index] = sort(distance, 'ascend');
    label = label(dis_index);
    FP = cumsum(label == -1, 1);
    TP = cumsum(label == 1, 1);
    FPR = FP/n_n;
    TPR = TP/n_p;
    % compute AUC
    AUC = trapz(FPR, TPR);
    
    % output
    varargout{1} = AUC;
    varargout{2} = FPR;
    varargout{3} = TPR;
    
    % plot the ROC curve
    f1 = figure;
    set(f1, 'unit', 'centimeters', 'position', [0 0 12 12]);
    plot(FPR, TPR,...
        'color', [254, 67, 101]/255,...
        'LineStyle', '-',...
        'LineWidth', 3)

    % axis settings
    tgca = 12;  % font size

    %     set(gca, 'yscale','log')
    set(gca, 'FontSize',tgca)

    % label settings
    tlabel = tgca*1.1;
    xlabel('False positive rate (FPR)',...
           'FontSize', tlabel,...
           'FontWeight', 'normal',...
           'Color', 'k')
    ylabel('True positive rate (TPR)',...
           'FontSize', tlabel,...
           'FontWeight', 'normal',...
           'Color', 'k')
    grid on
    titleString = ['Area under the curve (AUC) = ',num2str(AUC)];
    title(titleString,...
          'FontSize', tlabel,...
          'FontWeight', 'normal',...
          'Color','k')
    set(gca, 'linewidth', 1.1)
    hold off
end




