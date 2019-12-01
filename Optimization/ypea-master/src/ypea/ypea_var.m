function var = ypea_var(name, type, varargin)
    % Creates a Decision Variable Definition
    
    if ~exist('type', 'var')
        type = 'real';
    end
    
    var_type = ypea_get_var_type(type);
    
    if isempty(var_type)
        error('Unknown variable type specified.');
    end
    
    var.name = name;
    var.type = var_type.name;
    
    var.size = [];
    var.count = [];
    var.code_size = [];
    var.code_count = [];
    
    if ~isempty(var_type.props)
        for prop = var_type.props'
            var.props.(prop.name) = prop.default;
        end
    else
        var.props = [];
    end
    
    for i = 1:2:numel(varargin)
        key = lower(varargin{i});
        value = varargin{i+1};
        if ~strcmpi(key, 'size')
            switch key
                case 'lb'
                    key = 'lower_bound';
                    
                case 'ub'
                    key = 'upper_bound';
                    
            end
            
            var.props.(key) = value;
        else
            var.size = value;
        end
    end
    
    if ~isfield(var, 'size') || isempty(var.size)
        var.size = [1 1];
    end
    
    if isscalar(var.size)
        var.size = [1 var.size];
    end
    
    if prod(var.size) == 1
        if isfield(var.props, 'lower_bound')
            mm = var.props.lower_bound + var.props.upper_bound;
            if numel(mm) > 1
                var.size = size(mm);
            end
        end
    end
    
    var.code_size = ypea_get_var_code_size(var);
    
    var.count = prod(var.size);
    var.code_count = prod(var.code_size);
    
    decode = var_type.decode;
    var.decode = @(xhat) decode(ypea_clip(xhat, 0 ,1), var);
    
    var.generate_sample = @() ypea_generate_sample(var, true);
    var.generate_sample_code = @() ypea_generate_sample_code(var);
    
end
