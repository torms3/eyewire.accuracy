function [MAP_u_info] = DB_extract_user_info( cell_ID, period, t_status, v_status )

%% Argument validation
%
if( ~exist('cell_ID','var') )
    cell_ID = 0;
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
[where_clause] = DB_get_where_clause( cell_ID, period, t_status, v_status );


%% Create MAP_u_info
%
[MAP_u_info] = DB_create_MAP_user_info( where_clause );

end