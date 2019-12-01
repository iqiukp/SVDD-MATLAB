function var_type = ypea_define_var_type_real()
    % Defines the 'real' decision variable type
    
    var_type.name = 'real';
    
    var_type.alt_names = {'continuous'};
    
    var_type.props = [
        struct('name', 'lower_bound', 'default', 0)
        struct('name', 'upper_bound', 'default', 1)
    ];
    
    var_type.decode = @decode_var_real;
    
end

function x = decode_var_real(xhat, var)
    
    lb = var.props.lower_bound;
    ub = var.props.upper_bound;
    
    x = lb + (ub - lb) .* xhat;
    
end
