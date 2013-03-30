function [S,V] = USM_generate_user_segment_matrix( MAP_s_ui, META )
%% Argument description
%
%	MAP_s_ui:
%	META:		MAP_t_meta
%


%% Dimension
%
n_items_s1 	= META(0).offset_s1;
n_items_s0	= META(0).offset_s0;
n_users		= MAP_s_ui.Count;


%% s_ui
%
s1 = -ones(n_users,n_items_s1);
s0 = -ones(n_users,n_items_s0);
v1 = zeros(1,n_items_s1);
v0 = zeros(1,n_items_s0);


%% User-wise processing
%
uIDs 	= MAP_s_ui.keys;
vals	= MAP_s_ui.values;
for i = 1:MAP_s_ui.Count

	uID = uIDs{i};

	% fprintf( '%dth user_row (uID=%d) is now processing...\n', i, uID );

	MAP_user_row = vals{i};
	

	%% User-tasks
	%
	tIDs 	= MAP_user_row.keys;
	vals2	= MAP_user_row.values;
	for j = 1:MAP_user_row.Count

		tID = tIDs{j};
		meta = META(tID);
        
        % fprintf( '%dth user task (tID=%d) is now processing...\n', j, tID );

		% data element
		DE = vals2{j};
		chunk_s1 = DE.s1;
		chunk_s0 = DE.s0;
		
		idx_s1 = (1:numel(chunk_s1)) + meta.offset_s1;
		idx_s0 = (1:numel(chunk_s0)) + meta.offset_s0;

		s1(i,idx_s1) = chunk_s1;
		s0(i,idx_s0) = chunk_s0;

		v1(idx_s1) = meta.segvol_s1;
		v0(idx_s0) = meta.segvol_s0;

	end

end

S.s1 = s1;
S.s0 = s0;
V.v1 = v1;
V.v0 = v0;

end