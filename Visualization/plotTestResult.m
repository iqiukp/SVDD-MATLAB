function plotTestResult(model, result)
%{

DESCRIPTION
 Plot the testing results

      plotTestResult(model, result)

    INPUT
      model          SVDD model
      result         testing results


Created on 1st December by Kepeng Qiu.
-------------------------------------------------------------%

%}

    %
    f1 = figure(1);          
    set(f1, 'unit', 'centimeters', 'position', [0 0 20 10]);
    plot(model.radius*ones(size(result.distance,1), 1),...
        'color', [213, 81, 36]/255,...
        'LineStyle', '-',....
        'LineWidth', 2)
    hold on
    plot(result.distance,...
        'color', [125, 45, 141]/255,...
        'LineStyle', '-',....
        'LineWidth', 2)

    % axis settings
    tgca = 12;  % font size

%     set(gca, 'yscale','log')
    set(gca, 'FontSize',tgca)
    
    % legend settings
    tlegend = tgca*0.9;
    legend({'Radius', 'Distance'}, ...
            'FontSize', tlegend , ...
            'FontWeight', 'normal')

    % label settings
    tlabel = tgca*1.1; 
    xlabel( 'Samples',...
            'FontSize',tlabel,...
            'FontWeight','normal',...
            'Color','k')
    ylabel('Distance',...
           'FontSize', tlabel,...
           'FontWeight', 'normal',...
           'Color','k')
    % 
    set(gca, 'linewidth', 1.1)
    hold off
end