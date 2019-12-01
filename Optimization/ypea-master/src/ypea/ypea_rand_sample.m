function s = ypea_rand_sample(n, k)
    % Randomly selecting k samples from n items
    
    if ~exist('k', 'var')
        k = 1;
    end

    k = min(n, k);
    
    r = rand(1,n);
    [~, so] = sort(r);
    
    s = so(1:k);
    
end