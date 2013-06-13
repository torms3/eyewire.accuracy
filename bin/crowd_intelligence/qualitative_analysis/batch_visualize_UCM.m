function batch_visualize_UCM( update, cellIDs )

	% cellIDs = [33];
	% cellIDs = [10 11 12 28 29 30 33 34 35 37 39 40 41];

	period.since = '';
	period.until = '';
	t_status = [0 6 10];

	% update = true;

	[DB_MAP_path] = DB_get_DB_MAP_path();
	for i = 1:numel(cellIDs)

		cellID = cellIDs(i);
		fprintf('(%d/%d) cell %d is now processing...\n',i,numel(cellIDs),cellID);
		
		if( update )
			[DB_MAPs] = DB_construct_DB_MAPs( DB_MAP_path, false, cellID, period, t_status );
		else
			[fileName] = make_DB_MAPs_file_name( cellID );
			load([DB_MAP_path '/' fileName]);
		end

		[UCM] = visualize_user_cube_matrix( DB_MAPs, cellID );

	end

end