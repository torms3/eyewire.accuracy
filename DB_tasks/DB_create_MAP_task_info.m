function [T] = DB_create_MAP_task_info( where_clause )

%% MySQL
%

% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

% MySQL query 1:
% To make a validation list for each task (cube), 
% in which validations are ordered as a time series.
query_str = ['SELECT tasks.id,validations.id ' ...
             'FROM validations ' ...
             'INNER JOIN tasks ON task_id=tasks.id ' ...
            ];
query_str = [query_str where_clause];
query_str = [query_str 'ORDER BY validations.finish '];
[tIDs,vIDs] = mysql( query_str );

% MySQL query 2:
query_str = ['SELECT task_id,segments,seeds,channel_id,' ... 
             'cell,weight ' ...
             'FROM validations ' ...
             'INNER JOIN tasks ON task_id=tasks.id ' ...
             'WHERE user_id=0 ' ...
            ];

% [03/29/2013 kisuklee]
% Inner query approach is faster than the tID list construction one.
inner_query = get_qeury_for_affected_task_IDs( where_clause );
query_str = [query_str 'and tasks.id IN (' inner_query ')'];
% comma_separated_tIDs = regexprep(num2str(unique(tIDs)'),' +',',');
% query_str = [query_str 'and tasks.id IN (' comma_separated_tIDs ')'];

[task,seg,seed,channel,cell_IDs,weight] = mysql( query_str );

% MySQL close
mysql('close');


%% Extract task information
%
unique_tIDs = unique(tIDs);
nt = numel(unique_tIDs);
vals = cell(1,nt);
for i = 1:nt

    tID = unique_tIDs(i);
    idx = find(task == tID);
    assert( ~isempty(idx) );

    fprintf( '(%d / %d) task (ID=%d) is now processing...\n', i, nt, tID );
    
    % [01/17/2013 kisuklee] TODO
    % The formula for threshold should be parameterized.
    vals{i}.cell = cell_IDs(idx);
    vals{i}.weight = weight(idx);
    vals{i}.consensus = sort( extract_consensus( seg{idx}, exp( -0.16*weight(idx) ) + 0.2 ), 'ascend' );
    vals{i}.union = sort( segstr2seg( seg{idx} ), 'ascend' );
    vals{i}.seed = sort( segstr2seg( seed{idx} ), 'ascend' );
    vals{i}.chID = channel(idx);
    vals{i}.vIDs = vIDs(tIDs == tID);
    
    % this field should be filled later
    vals{i}.seg_size = [];

end

keys = num2cell(unique_tIDs);
T = containers.Map( keys, vals );

end


function [query_str] = get_qeury_for_affected_task_IDs( where_clause )

query_str = ['SELECT DISTINCT(tasks.id) ' ...
             'FROM validations ' ...
             'INNER JOIN tasks ON validations.task_id=tasks.id ' ...
            ];
query_str = [query_str,where_clause];
query_str = [query_str 'ORDER BY tasks.id'];

end