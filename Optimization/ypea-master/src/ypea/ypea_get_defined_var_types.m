function var_types = ypea_get_defined_var_types()
    % Gathers Variable Types Defined in YPEA Toolbox
    
    funcs = get_var_definition_funcs();
    
    for f = funcs'
        var_type = get_var_type(f{1});
        var_types.(var_type.name) = var_type;
    end
    
end

function funcs = get_var_definition_funcs()

    p = ypea_path();
    items = dir(fullfile(p, 'ypea_define_var_type_*.m'));
    
    funcs = cell(size(items));
    
    c = 0;
    for item = items'
        c = c + 1;
        [~, funcs{c}] = fileparts(item.name);
    end
    
end

function var_type = get_var_type(func)

    var_type = feval(func);

    names = [{var_type.name} var_type.alt_names];
    names = cellfun(@ypea_simplify_string, names, 'UniformOutput', false);
    
    var_type.check_name = @(name) check_name(name, names);
    
    % decode = var_type.decode;
    % var_type.decode = @(xhat, var) decode(ypea_clip(xhat, 0, 1), var);
   
end

function b = check_name(name, names)

    name = ypea_simplify_string(name);
    
    for i = 1:numel(names)
        if strcmpi(name, names{i})
            b = true;
            return;
        end
    end
    
    b = false;
    
end
