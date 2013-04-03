function [V] = DB_create_MAP_validation_info( where_clause )

%% MySQL
%

% MySQL open
mysql('open', '127.0.0.1:13306', 'omnidev', 'we8pizza');
mysql('use omniweb');

% MySQL query
query_str = ['SELECT validations.id,task_id,user_id, ' ...
             'segments,finish,weight,duration ' ...
             'FROM validations ' ...
             'INNER JOIN tasks ON task_id=tasks.id ' ...
            ];
query_str = [query_str,where_clause];
query_str = [query_str 'ORDER BY validations.id '];
[vIDs,tIDs,uIDs,seg,time,weight,dur] = mysql( query_str );

% MySQL close
mysql('close');


%% Extract validation information
%
nv = numel(vIDs);
for i = 1:nv

    fprintf( '(%d / %d) validation (ID=%d) is now processing...\n', i, nv, vIDs(i) );

    vals{i}.tID = tIDs(i);
    vals{i}.uID = uIDs(i);
    vals{i}.segs = segstr2seg( seg{i} );
    vals{i}.finish = time(i);
    vals{i}.weight = weight(i);
    vals{i}.duration = dur(i);
    
end

keys = num2cell(vIDs);
V = containers.Map( keys, vals );

end