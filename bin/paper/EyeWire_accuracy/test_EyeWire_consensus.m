function [result] = test_EyeWire_consensus( DB_MAPs, USM_data )

% Get hotspot cubes and super-user list
[hotspot_IDs,super_users] = get_VT_hotspots( DB_MAPs.V, DB_MAPs.T );


[super_uIDs,super_idx] = get_super_user_info( DB_MAPs.U, DB_MAPs.V );
[data] = CM_prepare_data( USM_data, super_idx );

s 		= data.S_ui;
v 		= data.V_i;
sigma 	= data.sigma;

n = sum(s > 0.5,1);
m = sum(s > -0.5,1);
prob = n./m;
prediction_exp = prob > min(0.99,(exp(-0.16*m) + 0.2));
err_exp = sigma - double(prediction_exp);
fn_idx = (err_exp > 0.5);
fp_idx = (err_exp < -0.5);

tIDs = unique(data.map_i_tID);
fpv = zeros(1,numel(tIDs));
fnv = zeros(1,numel(tIDs));
hot = zeros(1,numel(tIDs));
for i = 1:numel(tIDs)

	tID = tIDs(i);
	fpv(i) = (fp_idx & (data.map_i_tID==tID))*v';
	fnv(i) = (fn_idx & (data.map_i_tID==tID))*v';
	hot(i) = nnz(hotspot_IDs==tID);

end

result.tIDs = tIDs;
result.fpv = fpv;
result.fnv = fnv;
result.hot = hot;

end