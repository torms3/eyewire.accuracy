function [stat] = NUSM_compute_SAC_user_accuracy( data )

	t_status = [0];
	[SAC_tIDs] = get_SAC_challenge_tasks( t_status );

	% extract SAC information from data
	idx = ismember(data.map_tIDs,SAC_tIDs);
	SAC_data = data;
	SAC_data.tIDs = unique(data.map_tIDs(idx));
	SAC_data.map_tIDs = data.map_tIDs(idx);
	SAC_data.seed = data.seed(idx);
	SAC_data.sigma = data.sigma(idx);
	SAC_data.segSize = data.segSize(idx);
	SAC_data.matrix = data.matrix(:,idx);
	SAC_data.hotIDs = intersect(data.hotIDs,SAC_tIDs);

	% compute user accuracy on SAC
	[stat] = NUSM_compute_user_accuracy( SAC_data );

end