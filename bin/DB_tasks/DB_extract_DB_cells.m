function [cell_IDs] = DB_extract_DB_cells()

	%% MySQL
	%
	%	Extract unique cell IDs from EyeWire DB
	%
	% MySQL open
	mysql('open','127.0.0.1:13306','omnidev','we8pizza');
	mysql('use omniweb');

	% MySQL query
	query_str = ['SELECT id ' ...
	         	 'FROM cells ' ...
	         	 'ORDER BY id ' ...
	        	];
	[cell_IDs] = mysql( query_str );

	% MySQL close
	mysql('close');

end