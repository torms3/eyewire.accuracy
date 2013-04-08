function [img] = ST_aggregate_segment_triples( save_path )

% file name
file_name = 'tID_*';
[img] = get_aggregate( save_path, file_name );

end


function [aggregate] = get_aggregate( save_path, file_name )

	% get the list of data files
	file_list = dir([save_path file_name]);

	% temporary array for adding up all triples from each task (cube)
	max_dim = 300;
	aggregate = zeros(max_dim,max_dim,2);

	% for each data file
	n_files = numel(file_list);
	for i = 1:n_files

		triples = dlmread([save_path file_list(i).name]);
		dim = size(triples,1);
		triples = reshape(triples,[dim dim+1 2]);

		% pad array for adding up
		h_pad_dim = max_dim - size(triples,1);
		v_pad_dim = max_dim - size(triples,2);
		triples = padarray(triples,[h_pad_dim v_pad_dim],0,'post');
		aggregate = aggregate + triples;

	end

end