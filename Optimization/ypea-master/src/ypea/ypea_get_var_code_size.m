function s = ypea_get_var_code_size(var)
    % Calculates the Size of Code for a Variable
    
    s = var.size;

    if isfield(var.props, 'partition_count')
        s(2) = s(2) + var.props.partition_count - 1;
    end
    
end