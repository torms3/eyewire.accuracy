function [data] = PM_get_classifier_data( pre_data )	

% core data
data.S_ui = pre_data.S_ui;
data.V_i = pre_data.V_i;
data.sigma = pre_data.sigma;
data.map_i_tID = pre_data.map_i_tID;
data.map_u_uID = pre_data.map_u_uID;

% additional info.
[n_users,n_items] = size(data.S_ui);
data.n_users = n_users;
data.n_items = n_items;

% prior info
data.prior = extract_prior( data, 'cube', 'voxel' );

end