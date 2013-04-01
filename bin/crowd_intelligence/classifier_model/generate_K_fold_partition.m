function [k_fold] = generate_K_fold_partition( data, map_tIDs, K_tIDs, k )

S = data.S;
V = data.V;
T = map_tIDs;

idx = ismember( T.s1, K_tIDs{k} );
test.S.s1 = S.s1(:,idx);
test.V.v1 = V.v1(:,idx);

S.s1(:,idx) = [];
V.v1(:,idx) = [];
T.s1(:,idx) = [];
train.S.s1 = S.s1;
train.V.v1 = V.v1;

idx = ismember( T.s0, K_tIDs{k} );
test.S.s0 = S.s0(:,idx);
test.V.v0 = V.v0(:,idx);

S.s0(:,idx) = [];
V.v0(:,idx) = [];
T.s0(:,idx) = [];
train.S.s0 = S.s0;
train.V.v0 = V.v0;

k_fold.test = test;
k_fold.train = train;

end