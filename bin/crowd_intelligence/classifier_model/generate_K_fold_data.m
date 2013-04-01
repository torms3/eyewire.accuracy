function [k_fold] = generate_K_fold_data( data, k_idx, k )

s1 = data.S.s1;
s0 = data.S.s0;
v1 = data.V.v1;
v0 = data.V.v0;

assert( k_idx.n_s1 == size(s1,2) );
assert( k_idx.n_s0 == size(s0,2) );

% validation set
test.S.s1 = s1(:,k_idx.s1{k});
test.S.s0 = s0(:,k_idx.s0{k});
test.V.v1 = v1(:,k_idx.s1{k});
test.V.v0 = v0(:,k_idx.s0{k});

% training set
s1(:,k_idx.s1{k}) = [];
s0(:,k_idx.s0{k}) = [];
v1(:,k_idx.s1{k}) = [];
v0(:,k_idx.s0{k}) = [];

train.S.s1 = s1;
train.S.s0 = s0;
train.V.v1 = v1;
train.V.v0 = v0;

k_fold.test = test;
k_fold.train = train;

end