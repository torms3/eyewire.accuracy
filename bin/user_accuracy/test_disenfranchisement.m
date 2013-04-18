function [MAP_u_stat,MAP_stat_per_cell] = test_disenfranchisement( update, period, cell_IDs )

%%  Extract the IDs of cells that are updated during 
%	the specified period.
%
if( ~exist('cell_IDs','var') )
	[cell_IDs] = DB_extract_cell_IDs( period );
end


%% Create DB path
%
save_path = get_DB_MAP_path();
save_dir = ['DB_MAPs_',get_period_suffix( period )];
mkdir(save_path,save_dir);
DB_path = [save_path,save_dir,'/'];


%% Create user accuracy path
%
save_path = UA_get_project_data_path();
save_dir = ['user_accuracy_',get_period_suffix( period )];
mkdir(save_path,save_dir);
UA_path = [save_path,save_dir,'/'];


%%
% Cell-wise processing
%
vals = cell(size(cell_IDs));
for i = 1:numel(cell_IDs)

	cell_ID = cell_IDs(i);
	fprintf('%dth cell (cell_id=%d) is now processing...\n',i,cell_ID);

	if( update )

		% Extract DB MAPs
		[DB_MAPs] = DB_construct_DB_MAPs( DB_path, true, cell_ID, period );

		% Process user accuracy for this cell
		process_user_accuracy( UA_path, DB_MAPs, cell_ID );

	end

	% Cell-wise user stat
	vals{i} = UA_create_MAP_user_stat( cell_ID, period, UA_path, DB_path );

end

keys = num2cell(cell_IDs);
MAP_stat_per_cell = containers.Map( keys, vals );
file_name = 'MAP_stat_per_cell.mat';
save([UA_path,file_name],'MAP_stat_per_cell');


%% Create user accuracy MAP
%
[MAP_u_stat] = UA_aggregate_user_accuracy( cell_IDs, period, UA_path, DB_path );

end