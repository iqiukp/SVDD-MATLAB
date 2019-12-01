function str = ypea_simplify_string(str)
    % Simplifies a String
    str = lower(str);
    str = strrep(str, ' ', '');
    str = strrep(str, '-', '');
    str = strrep(str, '_', '');
    str = strrep(str, '.', '');
    
end