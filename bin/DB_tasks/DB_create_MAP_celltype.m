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
	SAC_IDs = [10 36 39 41 44];
	for i = 1:numel(SAC_IDs)
		MAP_celltype(SAC_IDs(i)) = 'sac';
	end

	keys = cell2mat(MAP_celltype.keys);
	cellIDs = [6 7 8 9 10 11 12 28 29 30 32 33 34 35 36 37 38 39 40 41 42 43 44];
	omittedIDs = setdiff(cellIDs,keys);
	for i = 1:numel(omittedIDs)
		MAP_celltype(omittedIDs(i)) = [''];
	end

end