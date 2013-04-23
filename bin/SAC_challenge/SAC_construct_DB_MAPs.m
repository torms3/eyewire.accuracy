function [DB_MAPs] = SAC_construct_DB_MAPs( seg_info, cell_IDs, t_status )

%% Argument validation
%
if( ~exist('seg_info','var') )
	seg_info = false;
end
if( ~exist('cell_IDs','var') )
	cell_IDs = [0];
end
if( ~exist('t_status','var') )
	t_status = [0 10];
end


%% Get SAC challenge tasks
%
[SAC_tIDs] = get_SAC_challenge_tasks( t_status );


%% Construct where clause
% period
period.since = '''2013-03-15 12:00:00''';
% period.since = '''2013-04-15 00:00:00''';
% period.until = '''2013-04-22 00:00:00''';
period.until = '';

% get WHERE clause
[where_clause] = get_where_clause( cell_IDs, period, t_status, 0 );

% SAC tasks
tIDs_str = regexprep(num2str(unique(SAC_tIDs)),' +',',');
where_clause = [where_clause 'AND tasks.id IN (' tIDs_str ') '];


%% Extract DB information
%
[U] 	= DB_create_MAP_user_info( where_clause );
[T] 	= DB_create_MAP_task_info( where_clause );
[V] 	= DB_create_MAP_validation_info( where_clause );
[VOL]	= DB_create_MAP_volume_info( where_clause );


%% Post-processing
%
if( seg_info )
	DB_extract_segment_size_info( T, VOL );
end


%% Return DB MAPs
%
DB_MAPs.U 	= U;
DB_MAPs.T 	= T;
DB_MAPs.V 	= V;
DB_MAPs.VOL = VOL;	

end