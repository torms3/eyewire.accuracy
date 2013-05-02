% function [param] = extract_prior( data )

	S_ui 	= data.S_ui;
	V_i 	= data.V_i;
	sigma 	= data.sigma;
	map_tID = data.map_i_tID;

	
	%% Supervoxel-based
	%
	TABLE 	= tabulate(map_tID(logical(sigma)));
	idx 	= ismember(TABLE(:,1),unique(map_tID));	
	s1 		= TABLE(idx,2);

	TABLE = tabulate(map_tID(~logical(sigma)));
	idx = ismember(TABLE(:,1),unique(map_tID));	
	s0 = TABLE(idx,2);


	%% Voxel-based
	%


	%% Prior
	%
	prior 	= zeros(size(sigma));



% end