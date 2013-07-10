function SA_raster_plot( DB_MAPs )

	T = DB_MAPs.T;
	V = DB_MAPs.V;

	% cubes (tasks)
	created = extractfield( cell2mat(T.values), 'datenum' );
	assert( issorted(created) );

	% validations
	finished = extractfield( cell2mat(V.values), 'datenum' );	
	weight = extractfield( cell2mat(V.values), 'weight' );

	% this can happen due to the GrimReaper correction
	if( ~issorted(finished) )
		[finished,idx] = sort(finished,'ascend');
		weight = weight(idx);
	end

	% v0 filtering
	v0_filter = (weight == 0);
	finished(v0_filter) = [];
	weight(v0_filter) = [];

	% GrimReaper cubes
	hot_filter = (weight > 10000);

	nc = numel(created);
	nv = numel(finished);
	nn = nc + nv;

	together = [created finished];
	spawn = zeros(size(together));
	spawn(1:nc) = 2;
	spawn([false(1,nc) hot_filter]) = 1;
	[~,idx] = sort(together,'ascend');
	spawn = spawn(idx);

	cols = 100;
	pad = zeros(1,ceil(nn/cols)*cols);
	pad(1:nn) = spawn;
	img = reshape(pad,100,[])';

	colormap(hot);
	imagesc(img);
	% axis equal;
	axis off;

end