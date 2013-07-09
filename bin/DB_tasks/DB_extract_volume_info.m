function [MAP_vol_info] = DB_extract_volume_info( chIDs )

%% MySQL
%

% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

% MySQL query 1
query_str = ['SELECT volumes.id,volumes.path,vx,vy,vz '...
             'FROM volumes ' ...
            ];
chIDs_str = regexprep(num2str(unique(chIDs)),' +',',');
where_clause = ['WHERE volumes.id IN (' chIDs_str ') '];
query_str = [query_str where_clause 'ORDER BY volumes.id '];
[id,vol_path,vx,vy,vz] = mysql( query_str );

% MySQL close
mysql('close');


%% Extract volume information
%
nvol = numel(id);
vals = cell(1,nvol);
for i = 1:nvol

	volPath = extract_local_volume_path( vol_path{i} );	
	vals{i}.path = volPath;

	% This field should be filled later
	vals{i}.n_seg = 0;
	% vals{i}.n_seg = get_total_num_of_segments( volPath );

	vals{i}.vx = vx(i);
	vals{i}.vy = vy(i);
	vals{i}.vz = vz(i);

end

keys = num2cell(id);
MAP_vol_info = containers.Map( keys, vals );

end


function [volPath] = extract_local_volume_path( volPathInDB )

homeVolumes = '/omelette/2/omniweb_data';

pos = strfind(volPathInDB,'/');
volPath = volPathInDB(pos(6)+1:pos(9)-1);
volPath = sprintf('%s/%s',homeVolumes,volPath);

end