function var_type = ypea_define_var_type_permutation()
    % Defines the 'permutation' decision variable type
    
    var_type.name = 'permutation';
    
    var_type.alt_names = {'perm'};
    
    var_type.props = [];
    
    var_type.decode = @decode_var_permutation;
    
end

function x = decode_var_permutation(xhat, ~)
    
    x = zeros(size(xhat));
    for i = 1:size(x,1)
        [~, x(i,:)] = sort(xhat(i,:));
    end
    
end
