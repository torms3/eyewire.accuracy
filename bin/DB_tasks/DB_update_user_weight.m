function DB_update_user_weight( uIDs, weight )

%% Argument validation
%
if( numel(uIDs) < 1 )
	return;
end


%% MySQL
%

% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

% MySQL query
query_string = ['UPDATE accounts ' ...
                'SET weight=%d ' ...                
               ];
query_string = sprintf(query_string,weight);

uIDs_str = regexprep(num2str(unique(uIDs)),' +',',');
where_clause = ['WHERE id IN (' uIDs_str ') '];

query_string = [query_string where_clause];

% execute the query
mysql( query_string );
% disp(query_string);

% MySQL close
mysql( 'close' );

end