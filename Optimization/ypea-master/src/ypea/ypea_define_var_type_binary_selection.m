function var_type = ypea_define_var_type_binary_selection()
    % Defines the 'binary_selection' decision variable type
    
    var_type.name = 'binary_selection';
    
    var_type.alt_names = {'binary_select', 'bin_selection', 'bin_select'};
    
    var_type.props = struct('name', 'selection_count', 'default', 1);
    
    var_type.decode = @decode_var_binary_selection;
    
end

function x = decode_var_binary_selection(xhat, var)
    
    selection_count = var.props.selection_count;
    selection_count = min(selection_count, size(xhat, 2));
    
    x = zeros(size(xhat));
    for i = 1:size(x,1)
        [~, q] = sort(xhat(i,:));
        x(i,q(1:selection_count)) = 1;
    end
    
end
