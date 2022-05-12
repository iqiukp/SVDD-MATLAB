classdef BinaryDataset < handle
    %{
        2D or 3D binary dataset for classification.

        Version 1.0, 13-MAY-2022
        Email: iqiukp@outlook.com

        -------------------------------------------------------------
        
        BSD 3-Clause License
        Copyright (c) 2022, Kepeng Qiu
        All rights reserved.
    %}

    properties
        % basic properties
        data
        label
        shape = 'banana' % shape of data: 'banana'or'circle'
        number = [200, 200] % number of samples per class
        dimensionality = 2 % 2 or 3
        display = 'on' % visualization:'on' or 'off'
        shuffle = 'off' % shuffle data

        % shape properties
        factor = 0.6 % scale factor (0-1) between two circles
        noise = 0.3
        angle = 120
        ratio = 0.3
        xlimt
        ylimt
        zlimt
        scatterSize = 32 % size of scatter
        zlimt_down = -1
        zlimt_up = 1
    end

    methods
        % create an object
        function obj = BinaryDataset(varargin)
            numParameter = numel(varargin)/2;
            if rem(numParameter, 1)
                error('Parameters should be pairs.')
            end

            for i = 1:numParameter
                obj.(varargin{(i-1)*2+1}) = varargin{1, i*2};
            end
        end

        % generate dataset
        function varargout = generate(obj)
            switch obj.shape
                case 'banana'
                    banana(obj);
                case 'circle'
                    circle(obj);
            end

            if strcmp(obj.shuffle, 'on')
                index_ = randperm(sum(obj.number));
                obj.data = obj.data(index_, :);
                obj.label = obj.label(index_, :);
            end

            if strcmp(obj.display, 'on')
                plot(obj)

            end

            if nargout == 1
                varargout{1, 1} = obj.data;
            end

            if nargout == 2
                varargout{1, 1} = obj.data;
                varargout{1, 2} = obj.label;
            end

            if nargout > 2
                errorText = sprintf([
                    'Incorrected output number.\n',...
                    '--------------------------\n',...
                    'ocdata.generate;\n', ...
                    'data = ocdata.generate;\n', ...
                    '[data, label] = ocdata.generate;.']);
                error(errorText)
            end
        end

        % banana-shaped dataset
        function banana(obj)
            class_p = linspace(0, 2*pi*obj.factor, obj.number(1, 1));
            class_n = linspace(0, 2*pi*obj.factor, obj.number(1, 2));

            class_p_x = cos(class_p)+obj.noise*rand(1, obj.number(1, 1));
            class_p_y = sin(class_p)+obj.noise*rand(1, obj.number(1, 1));

            class_n_x = 1-cos(class_n)+0.05+obj.noise*rand(1, obj.number(1, 2));
            class_n_y = 1-sin(class_n)-0.4+obj.noise*rand(1, obj.number(1, 2));

            obj.data = [[class_p_x', class_p_y']; [class_n_x', class_n_y']];
            obj.label = [ones(obj.number(1, 1), 1); -ones(obj.number(1, 2), 1)];

            if obj.dimensionality == 3
                [z_p, z_n] = getZAxisData(obj);
                obj.data = [[class_p_x', class_p_y', z_p]; [class_n_x', class_n_y', z_n]];
            end
            % rotate
            center_ = mean(obj.data);
            rotateMatrix = [cosd(obj.angle), -sind(obj.angle), 0;...
                sind(obj.angle), cosd(obj.angle), 0;...
                0 0 1];
            M1 = [1, 0, center_(1, 1);...
                0, 1, center_(1, 2);...
                0, 0, 1;];
            M2 = [1, 0, -center_(1, 1);...
                0, 1, -center_(1, 2);...
                0, 0, 1;];
            M = M1*rotateMatrix*M2;

            switch obj.dimensionality
                case 2
                    obj.data = [obj.data, ones(sum(obj.number),1)]*M;
                    obj.data = obj.data(:, 1:2);

                case 3
                    obj.data = obj.data*M;
            end
        end

        % circle-shaped dataset
        function circle(obj)
            class_p = linspace(0, 2*pi, obj.number(1, 1));
            class_n = linspace(0, 2*pi, obj.number(1, 2));

            class_p_x = cos(class_p)+obj.noise*rand(1, obj.number(1, 1));
            class_p_y = sin(class_p)+obj.noise*rand(1, obj.number(1, 1));

            class_n_x = cos(class_n)*obj.factor+obj.noise*rand(1, obj.number(1, 2));
            class_n_y = sin(class_n)*obj.factor+obj.noise*rand(1, obj.number(1, 2));

            obj.data = [[class_p_x', class_p_y']; [class_n_x', class_n_y']];
            obj.label = [ones(obj.number(1, 1), 1); -ones(obj.number(1, 2), 1)];
            if obj.dimensionality == 3
                [z_p, z_n] = getZAxisData(obj);
                obj.data = [[class_p_x', class_p_y', z_p]; [class_n_x', class_n_y', z_n]];
            end
        end

        % generate Z-axis data
        function [z_p, z_n] = getZAxisData(obj)
            z_p = obj.zlimt_down+(obj.zlimt_up-obj.zlimt_down)*...
                rand(obj.number(1, 1), 1);
            z_n = obj.zlimt_down+(obj.zlimt_up-obj.zlimt_down)*...
                rand(obj.number(1, 2), 1);
        end

        % partition dataset
        function [trainData, trainLabel, testData, testLabel] = partition(obj)
            index_ = crossvalind('HoldOut', sum(obj.number), obj.ratio, 'Min', 3);
            trainData = obj.data(index_, :);
            trainLabel = obj.label(index_, :);
            testData = obj.data(~index_, :);
            testLabel = obj.label(~index_, :);
        end

        % visualization
        function plot(obj)
            figure
            set(gcf, 'position', [300 150 640 480])
            hold on
            switch obj.dimensionality
                case 2
                    scatter(obj.data(obj.label==1, 1), ...
                        obj.data(obj.label==1, 2), ...
                        obj.scatterSize,...
                        'Marker', 'o',...
                        'MarkerEdgeColor', 'k', ...
                        'MarkerFaceColor', [31, 119, 180]/255)

                    scatter(obj.data(obj.label==-1, 1), ...
                        obj.data(obj.label==-1, 2), ...
                        obj.scatterSize,...
                        'MarkerEdgeColor', 'k', ...
                        'MarkerFaceColor', [148, 103, 189]/255)
                    title(['2D ', obj.shape, '-shaped dataset'])

                case 3
                    scatter3(obj.data(obj.label==1, 1), ...
                        obj.data(obj.label==1, 2), ...
                        obj.data(obj.label==1, 3), ...
                        obj.scatterSize,...
                        'Marker', 'o',...
                        'MarkerEdgeColor', 'k', ...
                        'MarkerFaceColor', [31, 119, 180]/255)

                    scatter3(obj.data(obj.label==-1, 1), ...
                        obj.data(obj.label==-1, 2), ...
                        obj.data(obj.label==-1, 3), ...
                        obj.scatterSize,...
                        'MarkerEdgeColor', 'k', ...
                        'MarkerFaceColor', [148, 103, 189]/255)

                    view([47 64])
                    title(['3D ', obj.shape, '-shaped dataset'])
            end

            %
            ratio_ = 0.2;
            axes_ = gca();
            range_x = axes_.XLim(1, 2)-axes_.XLim(1, 1);
            obj.xlimt  = [axes_.XLim(1, 1)-range_x*ratio_, ...
                axes_.XLim(1, 2)+range_x*ratio_];

            range_y = axes_.YLim(1, 2)-axes_.YLim(1, 1);
            obj.ylimt  = [axes_.YLim(1, 1)-range_y*ratio_, ...
                axes_.YLim(1, 2)+range_y*ratio_];
            %
            range_z = axes_.ZLim(1, 2)-axes_.ZLim(1, 1);
            obj.zlimt  = [axes_.ZLim(1, 1)-range_z*ratio_*3, ...
                axes_.ZLim(1, 2)+range_z*ratio_*3];

            box on
            grid on
            set(gca, 'LineWidth', 1.1, 'TickDir', 'in',...
                'XLim', obj.xlimt, 'YLim', obj.ylimt, 'ZLim', obj.zlimt);
        end
    end
end

