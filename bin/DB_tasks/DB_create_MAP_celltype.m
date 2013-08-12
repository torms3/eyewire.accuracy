function [MAP_celltype] = DB_create_MAP_celltype()

	%% MySQL
	%
	% MySQL open
	mysql('open','127.0.0.1:13306','omnidev','we8pizza');
	mysql('use omniweb');

	% MySQL query
	query_str = ['SELECT id,celltype ' ...
    	         'FROM cells ' ...
        	     'ORDER BY id ' ...
            	 ];
	[id,celltype] = mysql( query_str );

	% MySQL query
	query_str = ['SELECT DISTINCT(cell) ' ...
    	         'FROM tasks ' ...
    	         'WHERE status=0 ' ...
        	     'ORDER BY cell ' ...
            	 ];
	[cellIDs] = mysql( query_str );

	% MySQL close
	mysql('close');


	%% Create MAPs
	%
	% MAP( cellID -> celltype )
	keys = num2cell(id);
	vals = celltype;
	MAP_celltype = containers.Map( keys, vals );

	% [06/18/2013 kisuklee]
	%	TODO:
	%		modify DB (cells table)
	%
	SAC_IDs = [10 36 39 41 44 45 46 47 49 51 52 55 56 57 59];
	for i = 1:numel(SAC_IDs)
		MAP_celltype(SAC_IDs(i)) = 'sac';
	end

	keys = cell2mat(MAP_celltype.keys);	
	omittedIDs = setdiff(cellIDs,keys);
	for i = 1:numel(omittedIDs)
		MAP_celltype(omittedIDs(i)) = [''];
	end

end
