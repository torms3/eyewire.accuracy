function ST_plot_m_slice( img, m )

	assert(size(img,3) == 2);
	aggregate = img(:,:,1) + img(:,:,2);

	% slice data (fixed m)
	data = aggregate(m,1:m+1);


	%% Plot
	%
	colormap hot;
	xlim([-0.8 m+0.8]);	
	h = bar( 0:m, data, 1 );
	xlabel('n');
	title(sprintf('m = %d',m));
	colorbar;

	% bar coloring
	ch = get(h,'Children');
	fvd = get(ch,'Faces');
	fvcd = get(ch,'FaceVertexCData');
	[zs,izs] = sort(data);
	for j = 1:numel(data)
		row = izs(j);
		fvcd(fvd(row,:)) = zs(j);
	end
	set(ch,'FaceVertexCData',fvcd);
	
	% threshold
	th = m*min(0.99,exp(-0.16*m)+0.2);

	% draw decision line
	disp_th = floor(th) + 1 - 0.5;
	line([disp_th disp_th],ylim,'Color','b','LineWidth',2);


end