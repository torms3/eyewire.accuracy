function [USM_meta,USM_data] = USM_create_user_segment_matrix( DB_MAPs, exclude_v0, include_seed )

%% Argument validation
%
if( ~exist('exclude_v0','var') )
	exclude_v0 = false;
end
if( ~exist('include_seed','var') )
	include_seed = false;
end

%% Create MAP for task-segment metadata
%
fprintf('Creating MAP_t_meta ...\n');
[MAP_t_meta] = USM_create_MAP_task_segment_metadata( DB_MAPs.T, DB_MAPs.VOL, include_seed );


%% Create MAPs for user-segment data
%
fprintf('Creating MAP_user_segment ...\n');
[MAP_user_seg] = USM_create_MAP_user_segment( DB_MAPs, exclude_v0, include_seed );


%% Create MAPs for user-segment matrix data
%
fprintf('Creating MAP_user_segment_matrix ...\n');
[MAP_s_ui] = USM_create_MAP_user_segment_matrix( MAP_user_seg, MAP_t_meta );


%% Generate user-segment matrices s1, s0
%
fprintf('Finally generating user-segment matrix ...\n');
[S,V] = USM_generate_user_segment_matrix( MAP_s_ui, MAP_t_meta );


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
[map_u_uID] = USM_get_map_user_idx_to_uID( MAP_s_ui );
USM_data.map_u_uID = map_u_uID;

% seed idx
if( include_seed )
	[seed_idx] = USM_get_seed_idx( MAP_t_meta );
	USM_data.seed_idx = seed_idx;
end

end