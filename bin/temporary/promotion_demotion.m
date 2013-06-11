function [STAT,STAT_per_cell] = promotion_demotion( update, period, cell_IDs )

	%%  Extract the IDs of cells that are updated during 
	%	the specified period.
	%
	if( ~exist('cell_IDs','var') )
		[cell_IDs] = DB_extract_cell_IDs( period );
	end


	%% Create DB path
	%
	save_path = DB_get_DB_MAP_path();
	save_dir = ['DB_MAPs_' get_period_suffix( period )];
	mkdir(save_path,save_dir);
	DB_path = [save_path '/' save_dir];


	%% Create user accuracy path
	%
	save_path = UA_get_data_path();
	save_dir = ['user_accuracy_' get_period_suffix( period )];
	mkdir(save_path,save_dir);
	UA_path = [save_path '/' save_dir];


	%% Cell-wise processing
	%
	vals = cell(size(cell_IDs));
	for i = 1:numel(cell_IDs)

		cell_ID = cell_IDs(i);
		fprintf('%dth cell (cell_id=%d) is now processing...\n',i,cell_ID);

		if( update )

			% Extract DB MAPs
			[DB_MAPs] = DB_construct_DB_MAPs( DB_path, true, cell_ID, period );

			% Process user accuracy for this cell
			[UA] = UA_construct_user_accuracy( UA_path, false, DB_MAPs, cell_ID, period );

		end

		% Cell-wise user stat
		vals{i} = UA_create_MAP_uSTAT( UA, DB_MAPs );

	end

	keys = num2cell(cell_IDs);
	STAT_per_cell = containers.Map( keys, vals );
	file_name = 'STAT_per_cell.mat';
	save([UA_path '/' file_name],'STAT_per_cell');


	%% Create user accuracy MAP
	%
	[STAT] = UA_aggregate_user_accuracy( cell_IDs, period, UA_path, DB_path );

	file_name = 'STAT.mat';
	save([UA_path '/' file_name],'STAT');

end