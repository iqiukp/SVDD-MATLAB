function var_type = ypea_define_var_type_fixed_column_sum()
    % Defines the fixed 'column_sum' decision variable type

    var_type.name = 'fixed_column_sum';
    
    var_type.alt_names = {'column_sum', 'fixed_col_sum', 'col_sum'};
    
    var_type.props = struct('name', 'target', 'default', 0);
    
    var_type.decode = @decode_var_fixed_column_sum;
    
end

function x = decode_var_fixed_column_sum(xhat, var)
    
    target = var.props.target;
    if isscalar(target)
        target = repmat(target, [1 size(xhat,2)]);
    end
    if numel(target) ~= size(xhat,2)
        error('Number of column target elements does not match the number of columns.');
    end
    
    x = zeros(size(xhat));
    for j=1:size(xhat,2)
        x(:,j) = target(j) * xhat(:,j) / sum(xhat(:,j));
    end
    
end
