function sol = ypea_generate_sample(vars, unwrap)
    % Generates a Sample of a Given Variable or Variable Set (Array)
    
    if ~exist('unwrap', 'var')
        unwrap = false;
    end
    
    xhat = ypea_generate_sample_code(vars);
    sol = ypea_decode_solution(vars, xhat);
    
    if numel(vars) == 1 && unwrap
        sol = sol.(vars(1).name);
    end
    
end