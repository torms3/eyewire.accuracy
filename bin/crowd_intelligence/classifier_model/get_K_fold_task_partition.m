function [K_tIDs] = get_K_fold_task_partition( map_tIDs, K )

tIDs 		= union(unique(map_tIDs.s1),unique(map_tIDs.s0));
rand_idx 	= randperm(numel(tIDs));
n_k 		= floor(numel(tIDs)/K);

K_tIDs = cell(K,1);

for k = 1:K

	head_idx = n_k*(k - 1) + 1;
	tail_idx = head_idx + n_k - 1;

	if( k == K )
		K_tIDs{k} = tIDs(rand_idx(head_idx:end));
	else
		K_tIDs{k} = tIDs(rand_idx(head_idx:tail_idx));
	end

end

end