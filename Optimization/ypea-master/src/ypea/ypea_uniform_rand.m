function x = ypea_uniform_rand(lb, ub, varargin)
    % Generate Uniformly Distributed Random Numbers
    
    if ~exist('lb', 'var')
        lb = 0;
    end
    if ~exist('ub', 'var')
        ub = 1;
    end
    
    if isempty(varargin)
        mm = lb + ub;
        varargin{1} = size(mm);
    end
    
    x = lb + (ub - lb).*rand(varargin{:});
    
end