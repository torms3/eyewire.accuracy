function DB_update_user_accuracy_info( STAT, period )


	uIDs = cell2mat(STAT.keys);


	%% Update existing entries
	%

	% MySQL open
	mysql('open','127.0.0.1:13306','omnidev','we8pizza');
	mysql('use omniweb');

	scoretype = {'tp' 'fn' 'fp'};
	for i = 1:numel(scoretype)
		
		% MySQL query - true positive (tp)
		query_str = ['SELECT DISTINCT(user_id) ' ...
		     	 	 'FROM leaderboard ' ...
		         	 'WHERE timescale=''week'' AND start=''%s'' AND end=''%s'' ' ...
		         	 'AND scoretype=''%s'' ' ...
		         	 'ORDER BY user_id ' ...
		        	];
    	score_str = scoretype{i};
		query_str = sprintf(query_str,period.since,period.until,score_str);
		[ex_uIDs] = mysql( query_str );
		% disp(query_str);

		% update uIDs
		update_uIDs = intersect(ex_uIDs,uIDs);
		
		fieldName = [score_str 'v'];
		for j = 1:numel(update_uIDs)

			% MySQL query
			query_str = ['UPDATE leaderboard ' ...
					 	 'SET points=%d ' ...
					 	 'WHERE timescale=''week'' AND start=''%s'' AND end=''%s'' ' ...
		         	 	 'AND scoretype=''%s'' ' ...
					 	 'AND user_id=%d ' ...
						];
			uID = update_uIDs(j);
			fprintf('(%d/%d) uID = %d is now being updated...\n',j,numel(update_uIDs),uID);
			
			points = extractfield( STAT(uID), fieldName );
			query_str = sprintf(query_str,points,period.since,period.until,score_str,uID);
			
			% execute the query
			mysql( query_str );
			% disp(query_str);

		end

		%% Insert new entries
		%
		new_uIDs = setdiff(uIDs,update_uIDs);
		for j = 1:numel(new_uIDs)

			% MySQL query
			query_str = ['INSERT INTO leaderboard ' ...
						 '(user_id,timescale,start,end,points,scoretype) ' ...
					 	 'VALUES ' ...
						];
			uID = new_uIDs(j);
			fprintf('(%d/%d) uID = %d is now being inserted...\n',j,numel(new_uIDs),uID);			
			points = extractfield( STAT(uID), fieldName );

			% construct VALUES clause
			values = sprintf('(%d,''%s'',''%s'',''%s'',%d,''%s'')', ...
							 new_uIDs(j),'week',period.since,period.until,points,score_str);
			query_str = [query_str values];

			% execute the query
			mysql( query_str );
			% disp(query_str);

		end

	end

	% MySQL close
	mysql('close');

end