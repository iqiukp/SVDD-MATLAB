% DESCRIPTION
% Plot the results
%
%    plotResult(R,D)
%
% INPUT
%   R         Threshold
%   D         Distance
%
% Created by Kepeng Qiu on May 24, 2019.
%-------------------------------------------------------------%

function plotResult(R,D)

%
figure
plot(R*ones(size(D,1),1),'-','Linewidth',3,'color',[0.85 0.33 0.10], ...
    'MarkerSize',10,'MarkerEdgeColor',[0 0 0], ...
    'MarkerFaceColor',[0 0 0])
hold on
plot(D,'-o','Linewidth',1,'color',[0.49 0.18 0.56],'MarkerSize',5, ...
    'MarkerEdgeColor',[0.49 0.18 0.56], ...
    'MarkerFaceColor',[0.49 0.18 0.56])

% Axis settings
t_gca = 16;  % font size
% t_font = 'Helvetica'; % font type
t_font = 'Arial'; % font type
% set(gca,'yscale','log')
set(gca,'FontSize',t_gca,'FontName',t_font)

% legend settings
t_legend = t_gca*0.9;
legend({'Threshold','Distance'},'FontSize',t_legend , ...
    'FontWeight','normal','FontName',t_font)

% label settings
t_label = t_gca*1.1;
xlabel('Samples','FontSize',t_label,'FontWeight','normal', ...
    'FontName',t_font,'Color','k')
ylabel('Distance','FontSize',t_label,'FontWeight','normal', ...
    'FontName',t_font,'Color','k')

end
