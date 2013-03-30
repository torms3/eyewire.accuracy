function [MAP_s_ui] = USM_create_MAP_user_segment_matrix( MAP_us, META )
%% Argument description
%
%	MAP_us:		MAP_user_segment
%	META:		MAP_t_meta
%


%% User-wise processing
%
keys 	= MAP_us.keys;
vals 	= MAP_us.values;
for i = 1:MAP_us.Count
	
	uID = keys{i};

	% fprintf( '%dth user_row (u_id=%d) is now processing...\n', i, uID );

	[DE{i}] = process_each_user_row( vals{i}, META );

end

MAP_s_ui = containers.Map( keys, DE );

end


function [MAP_row] = process_each_user_row( MAP_user_row, META )

keys 	= MAP_user_row.keys;
vals 	= MAP_user_row.values;
for i = 1:MAP_user_row.Count

	tID 	= keys{i};
	val 	= vals{i};
	meta 	= META(tID);
	
	% a chuck of the s_ui matrix
	s_ui = zeros(1,meta.n_seg);
	s_ui(val.seg) = 1;

	% positive segments (sigma = 1)
	s1	= s_ui(meta.seg_s1);

	% negative segments (sigma = 0), among voted segmetns
	s0	= s_ui(meta.seg_s0);

	% negative segments (sigma = 0)
	s00 = s_ui(meta.seg_s00);

	% Data Element
	DE{i}.s1 	= s1;
	DE{i}.s0 	= s0;
	DE{i}.s00	= s00;
end

MAP_row = containers.Map( keys, DE );

end