function [where_clause] = get_where_clause( cell_IDs, period, t_status, v_status )

%% WHERE condition setting
%
t_status_str = get_condition_str( 'tasks.status', t_status );
v_status_str = get_condition_str( 'validations.status', v_status );
where_clause = ['WHERE ' t_status_str 'AND ' v_status_str];

% user_id 1 is reserved for reaping
where_clause = [where_clause 'AND (validations.user_id!=1) '];

% add cell clause, if any
[where_clause] = add_cell_clause( where_clause, cell_IDs );

% add period clause, if any
[where_clause] = add_period_clause( where_clause, period );

end