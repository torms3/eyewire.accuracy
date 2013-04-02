function [CHAT] = DB_extract_chat_info( where_clause )

%% Argument validtaion
%
if( ~exist('where_clause','var') )
	where_clause = '';
end


%% MySQL
% 

% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

% MySQL query 1:
% user information
query_str = ['SELECT user_id,message,sent ' ...
             'FROM chat ' ...
            ];
query_str = [query_str where_clause];
query_str = [query_str 'ORDER BY sent '];
[uIDs,msg,sent] = mysql( query_str );

% MySQL close
mysql('close');


%% Extract chat information
%
unique_uIDs = unique(uIDs);
nu = numel( unique_uIDs );
vals = cell(1,nu);
for i = 1:nu
    
    uID = unique_uIDs(i);
    fprintf( '(%d / %d) user (ID=%d) is now processing...\n', i, nu, uID );
        
    vals{i}.msg = msg(uIDs == uID);
    vals{i}.sent = sent(uIDs == uID);
    vals{i}.n_msg = numel(vals{i}.msg);
    
end

keys = num2cell(unique_uIDs);
CHAT = containers.Map( keys, vals );

end