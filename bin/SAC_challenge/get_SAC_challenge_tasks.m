function [SAC_tIDs] = get_SAC_challenge_tasks( t_status )

% SAC seeds
SAC1_seed = [18862 20445 20801 20991 22483 22609 22612 23259 25432 25438 25441 25452 25454 28823 29144 29162 29186 29209 29211 29363 30348 31873 31874 31884 31888 55442 55622 55917 55918 56225 56227 56228 56807 56808 56810 56847 56848 56849 56852 57201 57203 57204 57581 57585 59769 59770 59774 59987 59996 60446 60450 60453 60826 60829 61021 61022 61023 62725 62729 62731 63195 63197 63745 63749 63753 63755 63757 64321 64322 64323 64324 65105 65106 66105 66106 66142 66167 66213 66222 66238 66244 68019];
SAC2_seed = [58760 73992 75174 75555 75663 75815 76033 76222 76443];
Input2J = [20434 20445 20801 20979 20990 20991 20997 21594 21596 28823];
SAC_seed = union(SAC1_seed,SAC2_seed);
SAC_seed = union(SAC_seed,Input2J);


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