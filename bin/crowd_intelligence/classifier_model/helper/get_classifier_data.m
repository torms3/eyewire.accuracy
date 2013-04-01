function [data] = get_classifier_data( pre_data )	

% core data
data.s = pre_data.S_ui;
data.v = pre_data.V_i;
data.sigma = pre_data.sigma;
data.map_i_tID = pre_data.map_i_tID;

% additional info.
[n_users,n_items] = size(data.s);
data.n_users = n_users;
data.n_items = n_items;

end