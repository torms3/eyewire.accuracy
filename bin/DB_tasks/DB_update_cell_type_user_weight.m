function DB_update_cell_type_user_weight( cell_type, uIDs, weight )

%% Argument validation
%
assert( (weight == 1) || (weight == 0) );
if( numel(uIDs) < 1 )
	return;
end
[uIDs] = unique(uIDs);

% make sure that the uIDs is a row vector
[m,n] = size(uIDs);
if( n == 1 )
	uIDs = uIDs';
end


%% Update existing entries
%

% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

% MySQL query
query_str = ['SELECT DISTINCT(user_id) ' ...
     	 	 'FROM weights ' ...
         	 'WHERE celltype=''%s'' ' ...
         	 'ORDER BY user_id ' ...
        	];
query_str = sprintf(query_str,cell_type);
[ex_uIDs] = mysql( query_str );

% update uIDs
update_uIDs = intersect(ex_uIDs,uIDs);
if( ~isempty(update_uIDs) )

	% MySQL query
	query_str = ['UPDATE weights ' ...
			 	 'SET weight=%d ' ...
			 	 'WHERE user_id IN ('
				];
	query_str = sprintf(query_str,weight);

	% construct IN clause
	% in_clause = sprintf('%d',update_uIDs(1));
	% for i = 2:numel(update_uIDs)
		
	% 	in_clause = [in_clause ',%d'];
	% 	in_clause = sprintf(in_clause,update_uIDs(i));

	% end
	uIDs_str = regexprep(num2str(update_uIDs),' +',',');
	query_str = [query_str uIDs_str ')'];

	% execute the query
	% mysql( query_str );
	disp(query_str);
	
end


%% Insert new entries
%
new_uIDs = setdiff(uIDs,update_uIDs);
if( ~isempty(new_uIDs) )

	% MySQL query
	query_str = ['INSERT INTO weights (user_id,celltype,weight) ' ...
			 	 'VALUES ' ...
				];	


	% construct VALUES clause
	values = sprintf('(%d,''%s'',%d)',new_uIDs(1),cell_type,weight);
	for i = 2:numel(new_uIDs)
		
		values = [values ',(%d,''%s'',%d)'];
		values = sprintf(values,new_uIDs(i),cell_type,weight);

	end
	query_str = [query_str values];

	% execute the query
	% mysql( query_str );
	disp(query_str);

end

% MySQL close
mysql('close');

end