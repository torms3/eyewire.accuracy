function [SAC_tIDs] = get_SAC_tasks( t_status )

	%% MySQL
	%
	% MySQL open
	mysql('open','127.0.0.1:13306','omnidev','we8pizza');
	mysql('use omniweb');

	% MySQL query
	t_status_str = get_condition_str( 'tasks.status', t_status );
	query = ['SELECT DISTINCT(tasks.id) ' ...
			 'FROM tasks INNER JOIN cells on tasks.cell=cells.id ' ...
			 'WHERE ' t_status_str 'AND celltype=''sac'' ' ...
			];
	[SAC_tIDs] = mysql(query);

	% MySQL close
	mysql('close');

end