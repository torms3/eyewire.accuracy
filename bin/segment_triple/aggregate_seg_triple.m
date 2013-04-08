function [img] = aggregate_seg_triple( cell, mode )

	%% mode usage
	%
	% 	mode = 0 : all
	% 	mode = 1 : all - hotspots
	% 	mode = 2 : hotspots
	%
	if( ~exist('mode','var') )
	   mode = 0;
	end

	% file name
	file_name = sprintf( 'cell_%d*', cell );

	%% all
	data_path = './data/seg_triple/';
	img_all = get_aggregate( data_path, file_name );

	%% hotspots
	data_path = './data/seg_triple/hotspots/';
	img_hotspots = get_aggregate( data_path, file_name );

	%% return by mode
	if( mode == 0 )
		img = img_all;
	elseif( mode == 1 )
		img = img_all - img_hotspots;
	else
		img = img_hotspots;
	end	

end


function [aggregate] = get_aggregate( data_path, file_name )

	% get the list of data files
	file_list = dir( [data_path file_name] );

	% temporary array for adding up all triples from each task (cube)
	max_dim = 300;
	aggregate = zeros( max_dim, max_dim, 2 );

	% for each data file
	n_files = numel( file_list );
	for i = 1:n_files

		triples = dlmread( [data_path file_list(i).name] );
		dim = size( triples, 1 );
		triples = reshape( triples, [dim dim+1 2] );

		% pad array for adding up
		h_pad_dim = max_dim - size( triples, 1 );
		v_pad_dim = max_dim - size( triples, 2 );
		triples = padarray( triples, [h_pad_dim, v_pad_dim], 0, 'post' );
		aggregate = aggregate + triples;

	end

end