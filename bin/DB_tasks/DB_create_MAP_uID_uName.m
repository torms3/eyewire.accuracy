function [ID_name,name_ID] = DB_create_MAP_uID_uName()

	%% MySQL
	%
	% MySQL open
	mysql('open','127.0.0.1:13306','omnidev','we8pizza');
	mysql('use omniweb');

	% MySQL query
	query_str = ['SELECT id,username ' ...
    	         'FROM accounts ' ...
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
	ID_name = containers.Map( keys, vals );

	% MAP( username -> uID )
	name_ID = containers.Map( vals, keys );

end