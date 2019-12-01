function varargout = ypea_version()
    % Returns Version of YPEA Toolbox
    
    version = '1.0';
    
    if nargout > 0
        varargout{:} = version;
    else
        fprintf('\n');
        fprintf('YPEA\n');
        fprintf('Yarpiz Evolutionary Algorithms Toolbox\n');
        fprintf('ver = %s\n', version);
        fprintf('\n');
    end
    
end
