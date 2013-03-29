function DB_update_user_weight( uIDs, weight )

%% Argument validation
%
assert( (weight == 1) || (weight == 0) );
if( numel(uIDs) < 1 )
	return;
end
[uIDs] = unique(uIDs);

% make sure that the uIDs is row vector
[m,n] = size(uIDs);
if( n == 1 )
	uIDs = uIDs';
end


%% MySQL
%

% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

% MySQL query
query_str = ['UPDATE accounts ' ...
             'SET weight=%d ' ...
             'WHERE id IN (' ...
            ];
query_str = sprintf(query_str,weight);

% construct IN clause
comma_separated_uIDs = regexprep(num2str(uIDs),' +',',');
query_str = [query_str comma_separated_uIDs ')'];

% in_clause = sprintf('%d',uIDs(1));
% for i = 2:numel(uIDs)
	
% 	in_clause = [in_clause ',%d'];
% 	in_clause = sprintf(in_clause,uIDs(i));

% end
% query_str = [query_str in_clause ')'];

% execute the query
mysql( query_str );
% disp(query_str);

% MySQL close
mysql('close');

end