function [k_fold] = generate_K_fold_data( data, idx )

S = data.S_ui;
V = data.V_i;
s = data.sigma;
T = data.map_i_tID;

% validation set
test.S_ui 		= S(:,idx);
test.V_i 		= V(:,idx);
test.sigma 		= s(:,idx);
test.map_i_tID 	= T(:,idx);

% training set
S(:,idx) = [];
V(:,idx) = [];
s(:,idx) = [];
T(:,idx) = [];

train.S_ui 		= S;
train.V_i 		= V;
train.sigma 	= s;
train.map_i_tID = T;

% k-fold data
k_fold.test	 	= test;
k_fold.train 	= train;

end