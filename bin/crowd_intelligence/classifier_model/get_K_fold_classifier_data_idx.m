function [K_idx] = get_K_fold_classifier_data_idx( S, K )

s1 = S.s1;
s0 = S.s0;

n_s1 = size(s1,2);
n_s0 = size(s0,2);

n_k1 = floor(n_s1/K);
n_k0 = floor(n_s0/K);

rand_idx_s1 = randperm(n_s1);
rand_idx_s0 = randperm(n_s0);

% K-fold data index structure
K_idx.K 	= K;
K_idx.n_s1 	= n_s1;
K_idx.n_s0 	= n_s0;
K_idx.s1 	= cell(K,1);
K_idx.s0 	= cell(K,1);

for i = 1:K

	% s1: s(u,i) with sigma = 1
	start_idx 	= n_k1*(i - 1) + 1;
	end_idx 	= start_idx + n_k1 - 1;

	if( i == K )
		K_idx.s1{i} = rand_idx_s1(start_idx:end);		
	else
		K_idx.s1{i} = rand_idx_s1(start_idx:end_idx);
	end

	% s0: s(u,i) with sigma = 0
	start_idx 	= n_k0*(i - 1) + 1;
	end_idx 	= start_idx + n_k0 - 1;

	if( i == K )
		K_idx.s0{i} = rand_idx_s0(start_idx:end);
	else
		K_idx.s0{i} = rand_idx_s0(start_idx:end_idx);
	end

end

%% Validation
%
idx_s1 = [];
idx_s0 = [];
for i = 1:K

	idx_s1 = [idx_s1 K_idx.s1{i}];
	idx_s0 = [idx_s0 K_idx.s0{i}];

end
assert( isempty(setdiff(idx_s1,1:n_s1)) );
assert( isempty(setdiff(idx_s0,1:n_s0)) );
assert( isempty(setdiff(1:n_s1,idx_s1)) );
assert( isempty(setdiff(1:n_s0,idx_s0)) );

end