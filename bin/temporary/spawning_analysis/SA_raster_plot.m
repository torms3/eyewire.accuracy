function [w] = SA_raster_plot( DB_MAPs )

	T = DB_MAPs.T;
	V = DB_MAPs.V;

	created = extractfield( cell2mat(T.values), 'datenum' );
	assert( issorted(created) );
	finished = extractfield( cell2mat(V.values), 'datenum' );
	assert( issorted(finished) );
	weight = extractfield( cell2mat(V.values), 'weight' );
	w = weight;

	nc = numel(created);
	nv = numel(finished);
	nn = nc + nv;

	together = [created finished];
	spawn = zeros(size(together));
	spawn(1:nc) = 1;
	[~,idx] = sort(together,'ascend');
	spawn = spawn(idx);

	cols = 100;
	pad = zeros(1,ceil(nn/cols)*cols);
	pad(1:nn) = spawn;
	img = reshape(pad,100,[])';

	colormap(gray);
	imagesc(img);
	axis equal;
	axis off;

end