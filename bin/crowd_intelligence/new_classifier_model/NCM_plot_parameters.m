function [] = NCM_plot_parameters( MAP_param, stat )

	uIDs = cell2mat(MAP_param.keys());
	w = extractfield(cell2mat(MAP_param.values()),'w');
	theta = extractfield(cell2mat(MAP_param.values()),'theta');
	
	nv = log(stat.nCube);
	accumulate_mode = false;

	% plot pre-processing
	figure();
	set( gca, 'Color', 'k' );
	set( gcf, 'Color', 'k' );
	grid on;
	% grid minor;
	set( gca, 'XColor', 'w' );
	set( gca, 'YColor', 'w' );

	color = colormap( hot );

	hold on;

	% thresholding
	unit = 1;
	stage = 7;
	from = 0;
	to = stage;

	color = colormap( hot(stage+1) );
	for i = from:to

	    th = i;
	    
	    if( accumulate_mode )
	        idx = nv > th*unit;
	    else
	        lower_idx = (nv >= th*unit);
	        if( th == stage )
	            upper_idx = zeros(1,numel(nv));
	        else
	            upper_idx = (nv > (th+1)*unit);
	        end
	        idx = xor(lower_idx,upper_idx);
	    end	    
	    set( gca, 'Color', 'k' );
	    
	    caxis( [0 stage+1] );  
	    
	    circle_size = 40;
	    circle_shape = 'o';

	    h = scatter( theta(idx), w(idx), circle_size, circle_shape, ...
	                    'MarkerEdgeColor', 'k', ...
	                    'MarkerFaceColor', color(th+1,:) );
	end

	h = colorbar;
	ylabel(h,'Number of cubes (log-scale)');

	xlabel('\theta');
	ylabel('w');
	title('Parameter distribution for the model with non-negativity constraints','Color','w');

	% reference lines
	% line( xlim, [0 0], 'Color', 'r', 'LineWidth', 2 );
	% line( [0 0], ylim, 'Color', 'r', 'LineWidth', 2 );	

	hold off;
	
end