function test_generalization_for_vanilla_parameters( savePath, cellID, update )

%% DB
%
if( update )
	[DB_MAP_path] = DB_get_DB_MAP_path();
	[DB_MAPs] = DB_construct_DB_MAPs( DB_MAP_path, true, cellID );
else
	[fileName] = make_DB_MAPs_file_name( cellID );
	[DB_MAP_path] = DB_get_DB_MAP_path();
	fullPath = [DB_MAP_path '/' fileName];
	load(fullPath);
end


%% USM
%
include_seed = false;
[~,USM_data] = USM_create_user_segment_matrix( DB_MAPs, false, include_seed );
[~,USM_data1] = USM_create_user_segment_matrix( DB_MAPs, true, include_seed );


%% Super-user
%
[super_uIDs,super_idx] = get_super_user_info( DB_MAPs.U, DB_MAPs.V );
[data] = CM_prepare_data( USM_data, super_uIDs );
[data1] = CM_prepare_data( USM_data1, super_uIDs );


%% Test generalization
%
cellDir = sprintf('cell_%d',cellID);
mkdir(savePath,cellDir);
K = 5;
K_fold_vanilla_parameters( [savePath '/' cellDir], data, data1, K );

end