classdef DataSet < handle
    %{
        CLASS DESCRIPTION

        Banana-shaped dataset generation and partitioning
    
    -----------------------------------------------------------------
    %}
    methods(Static)
        function [data, label] = generate(varargin)
            numParameter = numel(varargin)/2;
            if rem(numParameter, 1)
                error('Parameters should be pairs.')
            end
            % Default settings
            display = 'on';
            dim = 2;
            numSamples = [200, 200];
            sizeBanana = 5;
            varBanana = 0.48;
            param_1 = 0.15;
            param_2 = 0.25;
            param_3 = 1.05;
            param_4 = -0.5; % x-axsis shift
            param_5 = -0.9;
            param_6 = 0;
            zlimt_down = -1;
            zlimt_up = 1;
            
            for i = 1:numParameter
                switch varargin{(i-1)*2+1}
                    case 'dim'
                        dim = varargin{i*2};
                    case 'num'
                        numSamples = varargin{i*2};
                    case 'display'
                        display = varargin{i*2};
                end
            end
            
            switch dim
                case 2
                    %
                    classP = param_1*pi+rand(1, numSamples(1))*param_3*pi;
                    data_p = [sizeBanana*sin(classP'), sizeBanana*cos(classP')]+randn(numSamples(1), 2)*varBanana;
                    label_p = ones(numSamples(1), 1);
                    %
                    classN = param_2*pi-rand(1, numSamples(2))*param_3*pi;
                    data_n = [sizeBanana*sin(classN'), sizeBanana*cos(classN')]+randn(numSamples(2), 2)*varBanana+...
                        ones(numSamples(2), 1)*[param_4*sizeBanana, param_5*sizeBanana];
                    label_n = -ones(numSamples(2), 1);
                    
                case 3
                    %
                    z = zlimt_down+(zlimt_up-zlimt_down)*rand(numSamples(1), 1);
                    zlimt_display_down = 10*zlimt_down;
                    zlimt_display_up = 10*zlimt_up;
                    %
                    classP = param_1*pi+rand(1, numSamples(1))*param_3*pi;
                    data_p = [sizeBanana*sin(classP'), sizeBanana*cos(classP'), z]+randn(numSamples(1), 3)*varBanana;
                    label_p = ones(numSamples(1), 1);
                    %
                    classN = param_2*pi-rand(1, numSamples(2))*param_3*pi;
                    data_n = [sizeBanana*sin(classN'), sizeBanana*cos(classN'), z]+randn(numSamples(2), 3)*varBanana+...
                        ones(numSamples(2), 1)*[param_4*sizeBanana, param_5*sizeBanana, param_6*sizeBanana];
                    label_n = -ones(numSamples(2), 1);
                    
                otherwise
                    error('Dimensionality of banana-shape data should be 2 or 3.')
            end
            %
            data = [data_p; data_n];
            label = [label_p; label_n];
            %
            if strcmp(display, 'on')
                scatterSize = 48;
                figure
                set(gcf, 'position', [300 150 640 480])
                hold on
                switch dim
                    case 2
                        scatter(data_p(:, 1), data_p(:, 2), scatterSize,...
                            'MarkerEdgeColor', 'k',...
                            'MarkerFaceColor', [31, 119, 180]/255)
                        scatter(data_n(:, 1), data_n(:, 2), scatterSize,...
                            'MarkerEdgeColor', 'k',...
                            'MarkerFaceColor', [148, 103, 189]/255)
                        box on
                        grid on
                        title('2D banana-shaped dataset')
                        
                    case 3
                        scatter3(data_p(:, 1), data_p(:, 2), data_p(:, 3), scatterSize,...
                            'MarkerEdgeColor', 'k',...
                            'MarkerFaceColor', [31, 119, 180]/255)
                        
                        scatter3(data_n(:, 1), data_n(:, 2), data_n(:, 3), scatterSize,...
                            'MarkerEdgeColor', 'k',...
                            'MarkerFaceColor', [148, 103, 189]/255)
                        box on
                        grid on
                        zlim([zlimt_display_down zlimt_display_up])
                        view([-47 35])
                        title('3D banana-shaped dataset')
                end
                set(gca, 'LineWidth', 1.1, 'TickDir', 'in');
            end
        end
        %
        function [trainData, trainLabel, testData, testLabel] = partition(data, label, varargin)
            numParameter = numel(varargin)/2;
            if rem(numParameter, 1)
                error('Parameters should be pairs.')
            end
            % Default settings
            type = 'hybrid';
            ratio = 0.3;
            for i = 1:numParameter
                switch varargin{(i-1)*2+1}
                    case 'type'
                        type = varargin{i*2};
                    case 'ratio'
                        ratio = varargin{i*2};
                end
            end
            index_p = (label == 1);
            n_p = sum(index_p);
            index_n = ~index_p;
            n_n = sum(index_n);
            data_p = data(index_p, :);
            data_n = data(index_n, :);
            label_p = ones(n_p, 1);
            label_n = -ones(n_n, 1);
            cv_p = crossvalind('HoldOut', n_p, ratio);
            switch type
                case 'single'
                    trainData = data_p(cv_p, :);
                    trainLabel = label_p(cv_p, :);
                    
                    testData = [data_p(~cv_p, :); data_n];
                    testLabel = [label_p(~cv_p, :); label_n];

                case 'hybrid'
                    rate_n = 0.9;
                    cv_n = crossvalind('HoldOut', n_n, rate_n);
                    
                    trainData = [data_p(cv_p, :); data_n(cv_n, :)];
                    trainLabel = [label_p(cv_p, :); label_n(cv_n, :)];
                    
                    testData = [data_p(~cv_p, :); data_n(~cv_n, :)];
                    testLabel = [label_p(~cv_p, :); label_n(~cv_n, :)];
            end
        end
    end
end