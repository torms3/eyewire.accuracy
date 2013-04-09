function [VOL] = DB_create_MAP_volume_info( where_clause )

%% MySQL
%

% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

% MySQL query 1
query_str = ['SELECT volumes.id,volumes.path '...
             'FROM volumes ' ...
             'INNER JOIN tasks ON volumes.id=tasks.channel_id ' ...             
            ];
[inner_query] = get_qeury_for_affected_task_IDs( where_clause );
query_str = [query_str 'AND tasks.id IN (' inner_query ') '];
query_str = [query_str 'ORDER BY volumes.id '];
[id,vol_path] = mysql( query_str );

% MySQL close
mysql('close');


%% Extract volume information
%
nvol = numel(id);
vals = cell(1,nvol);
for i = 1:nvol

	volPath = extract_local_volume_path( vol_path{i} );	
	vals{i}.path = volPath;
	% vals{i}.n_seg = get_total_num_of_segments( volPath );
	% This field should be filled later
	vals{i}.n_seg = 0;

end

keys = num2cell(id);
VOL = containers.Map( keys, vals );

end


function [volPath] = extract_local_volume_path( volPathInDB )

homeVolumes = '/omelette/2/omniweb_data';

pos = strfind( volPathInDB, '/' );
volPath = volPathInDB(pos(6)+1:pos(9)-1);
volPath = sprintf( '%s/%s', homeVolumes, volPath );

end


function [query_str] = get_qeury_for_affected_task_IDs( where_clause )

query_str = ['SELECT DISTINCT(tasks.id) ' ...
             'FROM validations ' ...
             'INNER JOIN tasks ON validations.task_id=tasks.id ' ...
            ];
query_str = [query_str where_clause];
query_str = [query_str 'ORDER BY tasks.id '];

end