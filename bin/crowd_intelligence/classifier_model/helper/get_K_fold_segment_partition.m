function [k_partition] = get_K_fold_segment_partition( data, K )

s1 = data.S_ui(:,logical(data.sigma));
s0 = data.S_ui(:,~logical(data.sigma));

n_s1 = size(s1,2);
n_s0 = size(s0,2);

n_k1 = floor(n_s1/K);
n_k0 = floor(n_s0/K);

rand_idx1 = randperm(n_s1);
rand_idx0 = randperm(n_s0);

% K-fold data index structure
k_partition = cell(K,1);
for k = 1:K

	head_idx = n_k1*(k - 1) + 1;
	tail_idx = min(n_s1,head_idx + n_k - 1);
	idx1 = rand_idx1(head_idx:tail_idx);

	head_idx = n_k0*(k - 1) + 1;
	tail_idx = min(n_s0,head_idx + n_0 - 1);
	idx0 = rand_idx0(head_idx:tail_idx);

	k_partition{k} = [idx1 idx0];

end

end