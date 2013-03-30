function [s1,s0,uIDs] = USM_generate_segment_user_matrix( MAP_s_iu, META )
%% Argument description
%
%	MAP_s_iu:
%	META:		MAP_t_meta
%


%% Dimension
%
n_items_s1 	= META(0).offset_s1;
n_items_s0	= META(0).offset_s0;

uIDs 	= get_uIDs( MAP_s_iu );
n_users = numel(uIDs);


%% s_ui
%
s1 = -ones(n_items_s1,n_users);
s0 = -ones(n_items_s0,n_users);


%% Cube-wise processing
%
keys 	= MAP_s_iu.keys;
vals	= MAP_s_iu.values;
for i = 1:MAP_s_iu.Count

	tID = keys{i};

	fprintf( '%dth cube_row (tID=%d) is now processing...\n', i, tID );

	MAP_cube_row = vals{i};
	

	%% User-tasks
	%
	keys2 	= MAP_cube_row.keys;
	vals2	= MAP_cube_row.values;
	for j = 1:MAP_cube_row.Count

		uID = keys2{j};
		meta = META(tID);

		% data element
		DE = vals2{j};
		chunk_s1 = DE.s1;
		chunk_s0 = DE.s0;
		
		idx_s1 = (1:numel(chunk_s1))' + meta.offset_s1;
		idx_s0 = (1:numel(chunk_s0))' + meta.offset_s0;

		u_idx = find(uIDs == uID);
		s1(idx_s1,u_idx) = chunk_s1;
		s0(idx_s0,u_idx) = chunk_s0;

	end

end

end


function [uIDs] = get_uIDs( MAP_s_iu )

uIDs = [];

%% Cube-wise processing
%
vals 	= MAP_s_iu.values;
for i = 1:MAP_s_iu.Count
	
	MAP_row = vals{i};
	uIDs = union( uIDs, cell2mat(MAP_row.keys) );

end

end