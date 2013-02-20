function [cell_IDs] = DB_extract_cell_IDs()

%% MySQL
%
%	Extract unique cell IDs from EyeWire DB
%
addpath './mysql/';

% MySQL open
mysql( 'open', '127.0.0.1:13306', 'omnidev', 'we8pizza' );
mysql( 'use omniweb' );

% MySQL query 1
query_string = ['SELECT DISTINCT(tasks.cell) '...
                'FROM validations ' ...
                'INNER JOIN tasks ON validations.task_id=tasks.id ' ...
                'WHERE validations.status=0 and tasks.status=0 ' ...
                'ORDER BY tasks.cell'];
[cell_IDs] = mysql( query_string );

% MySQL close
mysql( 'close' );

end