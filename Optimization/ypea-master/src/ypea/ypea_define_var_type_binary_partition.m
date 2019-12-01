function var_type = ypea_define_var_type_binary_partition()
    % Defines the 'binary_partition' decision variable type

    var_type.name = 'binary_partition';
    
    var_type.alt_names = {'binary_partitioning', 'binary_allocation', ...
                         'binary_alloc', 'bin_partitioning', ...
                         'bin_allocation', 'bin_alloc'};
    
    var_type.props = struct('name', 'partition_count', 'default', 1);
    
    var_type.decode = @decode_var_binary_partition;
    
end

function x = decode_var_binary_partition(xhat, var)
    
    partition_count = var.props.partition_count;
    item_count = size(xhat,2) - partition_count + 1;
    
    x = cell(size(xhat,1), 1);
    for i=1:numel(x)
        [~, qi] = sort(xhat(i,:));
        sep = find(qi > item_count);
        from = [0 sep] + 1;
        to = [sep (item_count + partition_count)] - 1;
        x{i} = zeros(partition_count, item_count);
        for j = 1:partition_count
            x{i}(j,qi(from(j):to(j))) = 1;
        end
    end
    if numel(x) == 1
        x = x{1};
    end
    
end
