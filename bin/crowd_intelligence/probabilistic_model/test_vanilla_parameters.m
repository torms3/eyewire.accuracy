cell_IDs = 11;


%% DB
%
[DB_MAP_path] = DB_get_DB_MAP_path();
% [DB_MAPs] = DB_construct_DB_MAPs( DB_MAP_path, true, cell_IDs );


%% USM
%
include_seed = true;
[~,USM_data] = USM_create_user_segment_matrix( DB_MAPs, false, include_seed );
[~,USM_data_wo_v0] = USM_create_user_segment_matrix( DB_MAPs, true, include_seed );


%% UA
%
[UA_data_path] = UA_get_data_path();
% [UA] = UA_process_user_accuracy( UA_data_path, DB_MAPs, cell_IDs );


%% uSTAT
%
% [uSTAT] = UA_create_MAP_uSTAT( UA, DB_MAPs );


%% Super-user
%
[super_uIDs,super_idx] = get_super_user_info( DB_MAPs.U, DB_MAPs.V );
[data] = CM_prepare_data( USM_data, super_uIDs );
[data_wo_v0] = CM_prepare_data( USM_data_wo_v0, super_uIDs );


%% vanilla parameter
%
[ERR] = vanilla_parameters( uSTAT, data, DB_MAPs );
[ERR_wo_v0] = vanilla_parameters( uSTAT, data_wo_v0, DB_MAPs );