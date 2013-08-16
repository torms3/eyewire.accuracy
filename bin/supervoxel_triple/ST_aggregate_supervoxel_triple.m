function [img] = ST_aggregate_supervoxel_triple( ST )
	
	max_dim = max(cellfun(@max,cellfun(@size,ST,'UniformOutput',false)));
	aggregate = zeros(max_dim,max_dim,2);

	for i = 1:numel(ST)

		triples = ST{i};
		fprintf('(%d/%d) %dth cube is now being processed...\n',i,numel(ST),i);

		% pad array for adding up
		h_pad = max_dim - size(triples,1);
		v_pad = max_dim - size(triples,2);
		triples = padarray(triples,[h_pad v_pad],0,'post');
		aggregate = aggregate + triples;

	end

	img = aggregate;

end