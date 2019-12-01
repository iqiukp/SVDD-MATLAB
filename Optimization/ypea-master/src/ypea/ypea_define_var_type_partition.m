function var_type = ypea_define_var_type_partition()
    % Defines the 'partition' decision variable type
    
    var_type.name = 'partition';
    
    var_type.alt_names = {'partitioning', 'allocation', 'alloc'};
    
    var_type.props = struct('name', 'partition_count', 'default', 1);
    
    var_type.decode = @decode_var_partition;
    
end

function x = decode_var_partition(xhat, var)
    
    partition_count = var.props.partition_count;
    item_count = size(xhat,2) - partition_count + 1;
    
    x = cell(size(xhat,1), 1);
    for i=1:numel(x)
        [~, qi] = sort(xhat(i,:));
        sep = find(qi > item_count);
        from = [0 sep] + 1;
        to = [sep (item_count + partition_count)] - 1;
        x{i} = cell(partition_count, 1);
        for j = 1:partition_count
            x{i}{j} = qi(from(j):to(j));
        end
    end
    if numel(x) == 1
        x = x{1};
    end
    
end
