function b = ypea_is_in_range(x, lb, ub)
    % Checks if a value is within a range or not
    b = all(x>=lb) && all(x<=ub);
    
end