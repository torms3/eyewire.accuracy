function [where_clause] = DB_get_where_clause( cell_ID, period, t_status, v_status )

%% WHERE condition setting
%
t_status_str = sprintf('tasks.status=%d ',t_status);
v_status_str = sprintf('validations.status=%d ',v_status);
where_clause = ['WHERE ' t_status_str 'AND ' v_status_str];

% user_id 1 is reserved for special use
where_clause = [where_clause 'AND user_id!=1 '];

% add cell clause, if any
[where_clause] = DB_add_cell_clause( where_clause, cell_ID );

% add period clause, if any
[where_clause] = DB_add_period_clause( where_clause, period );

end