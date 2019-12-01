function var_type = ypea_define_var_type_integer()
    % Defines the 'integer' decision variable type
    
    var_type.name = 'integer';
    
    var_type.alt_names = {'int', 'discrete'};
    
    var_type.props = [
        struct('name', 'lower_bound', 'default', 0)
        struct('name', 'upper_bound', 'default', 1)
    ];
    
    var_type.decode = @decode_var_integer;
    
end

function x = decode_var_integer(xhat, var)
    
    % TODO: remove floor and ceil for speed
    lb = floor(var.props.lower_bound);
    ub = ceil(var.props.upper_bound);
    
    x = lb + floor((ub - lb + 1) .* xhat);
    
end
