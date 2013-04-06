function [MAP_t_info] = DB_extract_task_info( cell_IDs, period, t_status, v_status )

%% Argument validation
%
if( ~exist('cell_IDs','var') )
    cell_IDs = [0];
end
if( ~exist('period','var') )
    period.since = '';
    period.until = '';
end
% tasks.status
if( ~exist('t_status','var') )
    t_status = 0;
end
% validations.status
if( ~exist('v_status','var') )
    v_status = 0;
end


%% Get WHERE clause
%
[where_clause] = get_where_clause( cell_IDs, period, t_status, v_status );


%% Create MAP_t_info
%
[MAP_t_info] = DB_create_MAP_task_info( where_clause );

end