function [STAT] = UA_aggregate_user_accuracy( cell_IDs, period, UA_path, DB_path )

%% Argument validation
%
if( ~exist('period','var') )
	period.since = '';
	period.until = '';
end
if( ~exist('cell_IDs','var') )
	[cell_IDs] = DB_extract_cell_IDs( period );
end
if( ~exist('UA_path','var') )
	UA_path = UA_get_data_path();
end
if( ~exist('DB_path','var') )
	DB_path = DB_get_DB_MAP_path();
end


%% Cell-wise processing
%
for i = 1:numel(cell_IDs)

	% print output
	cell_ID = cell_IDs(i);
	fprintf('%dth cell (cell_id=%d) is now processing...\n',i,cell_ID);

	% load user accuracy information	
	file_name = make_DB_MAPs_file_name( cell_ID, period );
	full_path = [DB_path file_name];
	load(full_path);	
	[new_STAT] = UA_create_MAP_user_stat( cell_ID, period, DB_MAPs, UA_path );

	% aggregate old and new MAPs
	if( i == 1 )
		STAT = new_STAT;
	else
		[STAT] = UA_merge_MAP_user_stat( STAT, new_STAT );
	end

end


%% Save STAT
%
file_name = 'STAT.mat';
save([UA_path file_name],'STAT');

end