function [TUT_T] = TUT_extract_tutorial_task_info()

%% MySQL
%

% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

% MySQL query
query_str = ['SELECT task_id,segments,seeds,channel_id ' ...
             'FROM validations ' ...
             'INNER JOIN tasks ON task_id=tasks.id ' ...
             'WHERE user_id=0 AND tasks.status=3 ' ...
            ];
[tIDs,seg,seed,channel] = mysql( query_str );

% MySQL close
mysql( 'close' );


%%
% Extract task information
%
nt = numel(tIDs);
for i = 1:nt

    tID = tIDs(i);
    fprintf('(%d / %d) task (id=%d) is now processing...\n',i,nt,tID);
    
    % [01/17/2013 kisuklee] TODO
    % The formula for threshold should be parameterized.
    vals{i}.union = segstr2seg( seg{i} );
    vals{i}.consensus = vals{i}.union;
    vals{i}.seed = segstr2seg( seed{i} );
    vals{i}.chID = channel(i);
    
    % this field should be filled later
    vals{i}.seg_size = [];

end

keys = num2cell(tIDs);
TUT_T = containers.Map( keys, vals );

end