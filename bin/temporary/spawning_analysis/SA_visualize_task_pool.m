function [] = SA_visualize_task_pool( DB_MAPs )
	
	% weight distribution
	[w,vw,hotspot] = SA_compute_weight_distribution( DB_MAPs );
	data = sort(vw,'descend');
	

	% plot
	subplot(2,1,1);
	colormap(jet);
	h = bar( data, 1 );	

	% bar coloring
	ch = get( h, 'Children' );
	fvd = get( ch, 'Faces' );
	fvcd = get( ch, 'FaceVertexCData' );
	[zs,izs] = sort(data);
	for j = 1:numel(data)
		row = izs(j);
		fvcd(fvd(row,:)) = zs(j);
	end
	set( ch, 'FaceVertexCData', fvcd );

	% decoration
	h = colorbar;
	ylabel(h,'Weight');

	xlabel('Cube index');
	ylabel('Cube weight');
	title('Mystery Cell #6 (cell ID = 48)');
	grid on;

end