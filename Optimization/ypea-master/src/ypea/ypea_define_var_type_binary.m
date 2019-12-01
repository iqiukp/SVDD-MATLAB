function var_type = ypea_define_var_type_binary()
    % Defines the 'binary' decision variable type

    var_type.name = 'binary';
    
    var_type.alt_names = {'bin'};
    
    var_type.props = [];
    
    var_type.decode = @decode_var_binary;
    
end

function x = decode_var_binary(xhat, ~)
    
    x = double(xhat >= 0.5);
    
end
