function [cell_IDs] = DB_extract_cell_type_IDs( cell_type )

%% MySQL
%
%	Extract cell IDs of the specified cell type from EyeWire DB
%

% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

% MySQL query
query_str = ['SELECT DISTINCT(id) '...
         	 'FROM cells ' ...         
         	 'WHERE celltype=''%s'' ' ...
         	 'ORDER BY id ' ...
        	];
query_str = sprintf(query_str,cell_type);
[cell_IDs] = mysql( query_str );

% MySQL close
mysql('close');

end