function [MAP_s_iu] = USM_create_MAP_segment_user_matrix( MAP_su, META )

%% Cube-wise
%
keys 	= MAP_su.keys;
vals 	= MAP_su.values;
for i = 1:MAP_su.Count

	tID = keys{i};

	fprintf( '%dth cube (t_id=%d) is now processing...\n', i, tID );

	[DE{i}] = process_each_cube_row( vals{i}, META(tID) );

end

MAP_s_iu = containers.Map( keys, DE );

end


function [MAP_row] = process_each_cube_row( cube_row, meta )

MAP_cube_row = cube_row.MAP_cube_row;

keys 	= MAP_cube_row.keys;
vals 	= MAP_cube_row.values;
for i = 1:MAP_cube_row.Count
	
	uID 	= keys{i};
	seg 	= vals{i};

	% a chuck of the s_iu matrix
	s_iu = zeros(meta.n_seg,1);
	s_iu(seg) = 1;

	% positive segments (sigma = 1)
	s1	= s_iu(meta.seg_s1);

	% negative segments (sigma = 0), among voted segmetns
	s0	= s_iu(meta.seg_s0);

	% negative segments (sigma = 0)
	% s00 = s_iu(meta.seg_s00);
	s00 = [];

	% Data Element
	DE{i}.s1 	= s1;
	DE{i}.s0 	= s0;
	DE{i}.s00	= s00;
	
end

MAP_row = containers.Map( keys, DE );

end