function [tracers] = DB_extract_tracer_uIDs()

	%% MySQL
	%
	% MySQL open
	mysql('open','127.0.0.1:13306','omnidev','we8pizza');
	mysql('use omniweb');

	% MySQL query
	query_str = ['SELECT id,username ' ...
    	         'FROM accounts ' ...
    	         'WHERE class=9 ' ...
        	     'ORDER BY id ' ...
            	 ];
	[uIDs,uName] = mysql( query_str );

	% MySQL close
	mysql('close');


	%% Create MAPs
	%
	% MAP( uID -> usernmae )
	keys = num2cell(uIDs);
	vals = uName;
	tracers = containers.Map( keys, vals );

end