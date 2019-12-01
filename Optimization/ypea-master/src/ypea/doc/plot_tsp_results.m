function plot_tsp_results(alg, ~, data)
    % Plots best tour ever found for TSP by algorithm (alg)

    x = data.x;
    y = data.y;
    
    figure(1);
    tour = alg.best_sol.solution.Tour;
    tour = tour([1:end 1]);
    plot(x(tour), y(tour), 'ko-', 'MarkerSize', 12, 'MarkerFaceColor', 'y');
    
    title("Tour Length = " + alg.best_sol.obj_value + " (iter = " + alg.iter + ")");
    xlim([0 100]);
    ylim([0 100]);
    grid on;
    axis equal;
    
    if alg.iter == 1 || mod(alg.iter, 10) == 0
        snapnow();
    end
    
    drawnow();
    
end