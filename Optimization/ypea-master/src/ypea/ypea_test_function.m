function f = ypea_test_function(func)
    % Ruturns function handle to predefined benchmark functions
    if ~exist('func', 'var') || isempty(func)
        error('Function name needed.');
    end
    
    f = str2func(func);

end

function z = sphere(x) %#ok
    z = sum(x.^2);
end

function z = ackley(x) %#ok
    z = 20*( 1 - exp(-0.2*sqrt(mean(x.^2)))) + exp(1) - exp(mean(cos(2*pi*x)));
end

function z = rosenbrock(x) %#ok
    z = sum( 100*(x(2:end) - x(1:end-1).^2).^2 + (x(1:end-1) - 1).^2 );
end

function z = rastrigin(x) %#ok
    A = 10;
    z = sum( x.^2 + A * (1 - cos(2*pi*x)));
end
