function sol = ypea_decode_solution(vars, xhat)
    % Decodes a coded vector and converts to structured solution
    
    n = ypea_get_total_code_length(vars);
    
    if numel(xhat) ~= n
        error('Invalid encoded solution length.');
    end
    
    c = 0;
    for i = 1:numel(vars)
        xhat_i = xhat(c + (1:vars(i).code_count));
        xhat_i = reshape(xhat_i, vars(i).code_size);
        x_i = vars(i).decode(xhat_i);
        sol.(vars(i).name) = x_i;
        c = c + vars(i).code_count;
    end
    
end