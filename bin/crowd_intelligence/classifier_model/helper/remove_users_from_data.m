function [data] = remove_users_from_data( USM_data, users )
%% Argument description
%
% 	USM_data = 
% 
%          S_ui: [1166x110075 double]
%           V_i: [1x110075 double]
%         sigma: [1x110075 double]
%     map_i_tID: [1x110075 double]
%
%	users:	user indices to remove (not uIDs, but indices)%

if( isempty(users) )
	return;
end

% read to local
S_ui 		= USM_data.S_ui;
V_i 		= USM_data.V_i;
sigma 		= USM_data.sigma;
map_i_tID 	= USM_data.map_i_tID;

% remove users
S_ui(users,:) = [];

% remove segments
valid_idx = S_ui > -1;
idx_to_remove = (sum(valid_idx.*S_ui,1) == 0);

S_ui(:,idx_to_remove) 		= [];
V_i(:,idx_to_remove) 		= [];
sigma(:,idx_to_remove) 		= [];
map_i_tID(:,idx_to_remove) 	= [];

% write to the result
data.S_ui 		= S_ui;
data.V_i 		= V_i;
data.sigma 		= sigma;
data.map_i_tID 	= map_i_tID;

end