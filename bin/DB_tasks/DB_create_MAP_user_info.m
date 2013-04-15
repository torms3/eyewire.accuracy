function [U] = DB_create_MAP_user_info( where_clause )

%% MySQL
% 

% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

% MySQL query 1:
% user information
query_str = ['SELECT id,username,weight ' ...
             'FROM accounts ' ...
             'ORDER BY id ' ...
            ];
[user,name,weight] = mysql( query_str );

% MySQL query 2:
query_str = ['SELECT user_id,validations.id ' ...
             'FROM validations ' ...
             'INNER JOIN tasks ON task_id=tasks.id ' ...
            ];
query_str = [query_str where_clause];
query_str = [query_str 'ORDER BY validations.finish '];
[uIDs,vIDs] = mysql( query_str );

% MySQL close
mysql('close');


%% Extract user information
%
unique_uIDs = unique(uIDs);
nu = numel( unique_uIDs );
vals = cell(1,nu);
for i = 1:nu
    
    uID = unique_uIDs(i);
    fprintf( '(%d / %d) user (ID=%d) is now processing...\n', i, nu, uID );
    
    vals{i}.username = cell2mat(name(user == uID));
    vals{i}.weight = weight(user == uID);
    vals{i}.vIDs = vIDs(uIDs == uID);
    vals{i}.nv = numel(vals{i}.vIDs);
    
end

keys = num2cell(unique_uIDs);
U = containers.Map( keys, vals );

end