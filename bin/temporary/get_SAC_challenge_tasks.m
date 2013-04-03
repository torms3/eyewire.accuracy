function [SAC_tIDs] = get_SAC_challenge_tasks()

% SAC seed
SAC_seed = unique([18862,20445,20801,20991,22483,22609,22612,23259,25432,25438,25441,25452,25454,28823,29144,29162,29186,29209,29211,29363,30348,31873,31874,31884,31888,55442,55622,55917,55918,56225,56227,56228]);


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
             	 'WHERE status=0 and left_edge>%d and right_edge<%d ' ...
            	];
	query_str = sprintf(query_str,left,right);
	[tIDs] = mysql( query_str );
	if( ~isempty(tIDs) )
		child = [child;tIDs];
	end

end

SAC_tIDs = union(SAC_seed,child);

end