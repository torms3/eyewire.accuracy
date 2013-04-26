function test_vanilla_parameters( savePath, cellIDs, update )

%% DB
%
if( update )
	[DB_MAP_path] = DB_get_DB_MAP_path();
	[DB_MAPs] = DB_construct_DB_MAPs( DB_MAP_path, true, cellIDs );
else
	[fileName] = make_DB_MAPs_file_name( cellIDs );
	[DB_MAP_path] = DB_get_DB_MAP_path();
	fullPath = [DB_MAP_path '/' fileName];
	load(fullPath);
end


%% USM
%
include_seed = false;
[~,USM_data] = USM_create_user_segment_matrix( DB_MAPs, false, include_seed );
[~,USM_data_wo_v0] = USM_create_user_segment_matrix( DB_MAPs, true, include_seed );


%% UA
%
if( update )
	[UA_data_path] = UA_get_data_path();
	[UA] = UA_construct_user_accuracy( UA_data_path, include_seed, DB_MAPs, cellIDs );
else
	[fileName] = make_UA_file_name( cellIDs );
	[UA_data_path] = UA_get_data_path()
	fullPath = [UA_data_path '/' fileName];
	load(fullPath);
end


%% uSTAT
%
[uSTAT] = UA_create_MAP_uSTAT( UA, DB_MAPs );


%% Super-user
%
[super_uIDs,super_idx] = get_super_user_info( DB_MAPs.U, DB_MAPs.V );
[data] = CM_prepare_data( USM_data, super_uIDs );
[data_wo_v0] = CM_prepare_data( USM_data_wo_v0, super_uIDs );


%% Vanilla parameter
%
[ERR] = vanilla_parameters( uSTAT, data, DB_MAPs );
[ERR_wo_v0] = vanilla_parameters( uSTAT, data_wo_v0, DB_MAPs );


%% Save the results
%
cellIDs_str = regexprep(num2str(unique(cellIDs)),' +','_');
fileName = sprintf('ERR__cell_%s.mat',cellIDs_str);
save([savePath '/' fileName],'ERR','ERR_wo_v0');

end