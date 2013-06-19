function [cell_IDs] = DB_extract_cell_IDs( period, t_status )

%% Argument validation
%
if( ~exist('period','var') )
    period.since = '';
    period.until = '';
end
if( ~exist('t_status','var') )
	t_status = [0];
end


%% MySQL
%
%	Extract unique cell IDs from EyeWire DB
%

% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

% MySQL query 1
query_str = ['SELECT DISTINCT(tasks.cell) ' ...
         	 'FROM validations ' ...
         	 'INNER JOIN tasks ON validations.task_id=tasks.id ' ...
        	];

% get WHERE clause
[where_clause] = get_where_clause( 0, period, t_status, 0 );

query_str = [query_str where_clause 'ORDER BY tasks.cell '];
[cell_IDs] = mysql( query_str );

% MySQL close
mysql('close');

end