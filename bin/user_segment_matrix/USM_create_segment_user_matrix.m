function [USM_meta,USM_data] = USM_create_segment_user_matrix( DB_MAPs )

%% Create MAP for task-segment metadata
%
fprintf('Creating MAP_t_meta ...\n');
[MAP_t_meta] = USM_create_MAP_task_segment_metadata( DB_MAPs.T, DB_MAPs.VOL );


%% Create MAPs for segment-user data
%
fprintf('Creating MAP_user_segment ...\n');
[MAP_seg_user] = USM_create_MAP_segment_user( DB_MAPs.T, DB_MAPs.V, DB_MAPs.VOL );


%% Create MAPs for segment-user matrix data
%
fprintf('Creating MAP_user_segment_matrix ...\n');
[MAP_s_iu] = USM_create_MAP_segment_user_matrix( MAP_seg_user, MAP_t_meta )


%% Generate user-segment matrices s1, s0
%
fprintf('Finally generating user-segment matrix ...\n');
[S,V] = USM_generate_user_segment_matrix( MAP_s_ui, MAP_t_meta );
[s1,s0,uIDs] = USM_generate_segment_user_matrix( MAP_s_iu, MAP_t_meta )


%% Resulting data
%

% meda data
USM_meta.MAP_t_meta = MAP_t_meta;
USM_meta.MAP_user_seg = MAP_user_seg;
USM_meta.MAP_s_ui = MAP_s_ui;

% core data
USM_data.S_ui = [S.s1 S.s0];
USM_data.V_i = [V.v1 V.v0];
USM_data.sigma = [ones(1,size(S.s1,2)) zeros(1,size(S.s0,2))];
[map_i_tID] = USM_get_map_seg_idx_to_tID( MAP_t_meta );
USM_data.map_i_tID = [map_i_tID.s1 map_i_tID.s0];

end