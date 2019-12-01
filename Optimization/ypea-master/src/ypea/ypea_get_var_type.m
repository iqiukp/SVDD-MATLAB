function var_type = ypea_get_var_type(name)
    % Determines the Type of a Decision Variable
    
    var_types = ypea_get_defined_var_types();
    
    types = fields(var_types);
    for type = types'
        vt = var_types.(type{1});
        if vt.check_name(name)
            var_type = vt;
            return;
        end
    end
    
    var_type = [];
    
end