function [process_time] = DB_weekly_update()

	%% Period setting
	%
	today = datestr(datenum(date),'yyyy-mm-dd');
	midnight = '00:00:00';

	period.since = '';
	period.until = sprintf('''%s''',[today ' ' midnight]);


	%% Cell IDs
	%
	t_status = [0];		% only active cubes
	[cell_IDs] = DB_extract_cell_IDs( period, t_status );

	
	%% Cell-wise processing
	%
	DB_path = DB_get_DB_MAP_path();
	savePath = [DB_path '/with_segSize_info'];
	mkdir(savePath);
	process_time = zeros(numel(cell_IDs));
	for i = 1:numel(cell_IDs)

		cellID = cell_IDs(i);
		
		tic;		
		DB_construct_DB_MAPs( savePath, true, cellID, period, t_status );
		process_time(i) = toc;

	end

	disp(['Elapsed time: ' num2str(sum(process_time))]);

end