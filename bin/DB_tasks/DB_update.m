function [process_time] = DB_update( current, cell_IDs )

	%% Argument validation
	%
	if( ~exist('cell_IDs','var') )
		% [cell_IDs] = DB_extract_DB_cells();
		[cell_IDs] = DB_extract_cell_IDs();
	end

	cell_IDs(cell_IDs <= 270) = [];

	%% Period setting
	%	
	today = datestr(datenum(date),'yyyy-mm-dd');
	midnight = '00:00:00';

	period.since = '';
	if( current )
		period.until = '';
	else
		period.until = sprintf('''%s''',[today ' ' midnight]);
	end

	
	%% Cell-wise processing
	%
	t_status = [0];		% only active cubes
	DB_path = DB_get_DB_MAP_path();
	savePath = [DB_path '/with_segSize_info'];
	[b_since,b_until] = check_period( period );
	if( b_since | b_until )
		savePath = [savePath '/DB_MAPs_' get_period_suffix( period )];
	end
	mkdir(savePath);
	process_time = zeros(numel(cell_IDs),1);
	for i = 1:numel(cell_IDs)

		cellID = cell_IDs(i);
		disp(['Processing cell ' num2str(cellID) ' now...']);
		
		tic;		
		DB_construct_DB_MAPs( savePath, true, cellID, period, t_status );
		process_time(i) = toc;

	end

	disp(['Elapsed time: ' num2str(sum(process_time))]);

end