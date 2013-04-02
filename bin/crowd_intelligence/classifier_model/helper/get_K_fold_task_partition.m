function [k_partition] = get_K_fold_task_partition( map_i_tID, K )

tIDs 		= unique(map_i_tID);
rand_idx 	= randperm(numel(tIDs));
n_k 		= floor(numel(tIDs)/K);

k_partition = cell(K,1);
for k = 1:K

	head_idx = n_k*(k - 1) + 1;
	tail_idx = min(numel(tIDs),head_idx + n_k - 1);
	k_partition{k} = ismember(map_i_tID,tIDs(rand_idx(head_idx:tail_idx)));

end

end