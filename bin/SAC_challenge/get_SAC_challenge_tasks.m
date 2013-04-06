function [SAC_tIDs] = get_SAC_challenge_tasks( t_status )

% SAC seeds
SAC_seed = unique([20434,20445,20801,20979,20990,20991,20997,21594,21596,22480,22481,22483,22490,22609,22612,23259,25392,25397,25432,25438,25439,25441,25442,25452,25454,28823,29143,29144,29162,29165,29185,29186,29199,29202,29209,29211,29260,29266,29321,29322,29340,29363,30345,30346,30348,31873,31874,31875,31882,31884,31886,31888,55442,55622,55917,55918,56225,56227,56228,56807,56808,56810]);


%% MySQL
%

% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

child = [];
n_seed = numel(SAC_seed);
for i = 1:n_seed

	tID = SAC_seed(i);
	fprintf('(%d / %d) seed (ID=%d) is now processing...\n',i,n_seed,tID);

	query_str = ['SELECT left_edge,right_edge ' ...
             	 'FROM tasks ' ...
             	 'WHERE id=%d ' ...
            	];
	query_str = sprintf(query_str,tID);
	[left,right] = mysql( query_str );

	% extract descendent tasks
	query_str = ['SELECT id ' ...
             	 'FROM tasks ' ...
             	 'WHERE left_edge>%d AND right_edge<%d ' ...
            	];
	query_str = sprintf(query_str,left,right);
	t_status_str = get_condition_str( 'tasks.status', t_status );
	query_str = [query_str 'AND ' t_status_str];
	[tIDs] = mysql( query_str );
	if( ~isempty(tIDs) )
		child = [child;tIDs];
	end

end

SAC_tIDs = union(SAC_seed,child);

% MySQL close
mysql('close');

end