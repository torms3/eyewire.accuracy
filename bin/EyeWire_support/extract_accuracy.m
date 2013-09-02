function [STAT] = extract_accuracy( period, celltype )

	%% Argument validations
	%
	if( ~exist('celltype','var') )
		celltype = '';
	end


	%% Options
	%	
	t_status = [0];


	%% Cell IDs
	%
	[cellIDs] = DB_extract_cell_IDs( period, t_status );
	if( strcmp(celltype,'sac') )
		[MAP_celltype] = DB_create_MAP_celltype();
		keys = cell2mat(MAP_celltype.keys);
		vals = MAP_celltype.values;
		cellIDs = intersect(cellIDs,keys(strcmp(vals,'sac')));
	end
	disp(cellIDs)


	%% Global
	%
	% update = true;
	% [STAT,~] = process_user_stat( update, period, t_status, cellIDs );

end