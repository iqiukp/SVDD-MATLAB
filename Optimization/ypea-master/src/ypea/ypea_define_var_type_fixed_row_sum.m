function var_type = ypea_define_var_type_fixed_row_sum()
    % Defines the fixed 'row_sum' decision variable type

    var_type.name = 'fixed_row_sum';
    
    var_type.alt_names = {'row_sum'};
    
    var_type.props = struct('name', 'target', 'default', 0);
    
    var_type.decode = @decode_var_fixed_row_sum;
    
end

function x = decode_var_fixed_row_sum(xhat, var)
    
    target = var.props.target;
    if isscalar(target)
        target = repmat(target, [size(xhat,1) 1]);
    end
    if numel(target) ~= size(xhat,1)
        error('Number of row target elements does not match the number of rows.');
    end
    
    x = zeros(size(xhat));
    for i=1:size(xhat,1)
        x(i,:) = target(i) * xhat(i,:) / sum(xhat(i,:));
    end
    
end
