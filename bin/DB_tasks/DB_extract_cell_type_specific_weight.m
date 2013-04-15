function [uIDs,w] = DB_extract_cell_type_specific_weight( cell_type )

%% MySQL
%

% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

% MySQL query:
query_str = ['SELECT user_id,weight ' ...
             'FROM weights ' ...
             'WHERE celltype=''%s'' ' ...
            ];
query_str = sprintf(query_str,cell_type);
query_str = [query_str 'ORDER BY user_id '];
% disp(query_str);
[uIDs,w] = mysql( query_str );

% MySQL close
mysql('close');

end