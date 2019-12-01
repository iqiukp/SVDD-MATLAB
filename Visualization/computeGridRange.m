function x_range = computeGridRange(x, varargin)
    %{ 
    DESCRIPTION
        Compute the range of grid 

          x_range = computeGridRange(x)
          x_range = computeGridRange(x, 'r', 0.2)
          x_range = computeGridRange(x, 'n', 200)
          x_range = computeGridRange(x, 'r', 0.2, 'n', 200)

        INPUT
          x            training inputs (N*1)
                       N: number of samples
          r            radio of expansion (0<r<1)
          n            number of grids

        OUTPUT
          x_range      range of grid

    Created on 1st December 2019, by Kepeng Qiu.
    -------------------------------------------------------------%
    %} 

    % default parameters setting
    r = 0.3;           % radio of expansion (0<r<1)
    n = size(x, 1)/2;  % number of grids
    % parameter setting
    if ~rem(nargin, 2)
        error('Parameters should be pairs.')
    end
    nParameter = (nargin-1)/2;
    if nParameter ~= 0
        for i =1:nParameter
            Parameters = varargin{(i-1)*2+1};
            value	= varargin{(i-1)*2+2};
            switch Parameters
                %
                case 'r'
                    r = value;
                    %
                case 'n'
                    n = value;
            end
        end
    end

    xlim_1 = min(x)-(max(x)-min(x))*r;  
    xlim_2 = max(x)+(max(x)-min(x))*r;  
    % range of grid
    x_range = linspace(xlim_1, xlim_2, n);
end
