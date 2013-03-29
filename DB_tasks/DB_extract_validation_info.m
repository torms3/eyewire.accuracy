function [MAP_v_info] = DB_extract_validation_info( cell_ID, period, t_status, v_status )

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
[where_clause] = get_where_clause( cell_ID, period, t_status, v_status );


%% Create MAP_v_info
%
[MAP_v_info] = DB_create_MAP_validation_info( where_clause );

end