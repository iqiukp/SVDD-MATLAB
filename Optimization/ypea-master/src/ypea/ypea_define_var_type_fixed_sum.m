function var_type = ypea_define_var_type_fixed_sum()
    % Defines the fiexd 'sum' decision variable type

    var_type.name = 'fixed_sum';
    
    var_type.alt_names = {'sum'};
    
    var_type.props = struct('name', 'target', 'default', 0);
    
    var_type.decode = @decode_var_fixed_sum;
    
end

function x = decode_var_fixed_sum(xhat, var)
    
    target = var.props.target;
    if ~isscalar(target)
        error('Target must be scalar.');
    end
    
    x = target * xhat / sum(xhat(:));
    
end
