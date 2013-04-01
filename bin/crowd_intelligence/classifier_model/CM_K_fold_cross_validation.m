function CM_K_fold_cross_validation( save_path, data, setting, K, map_tIDs )
%% Argument description
%
%	save_path
%
%	pre_data:
%		pre_data.S:
%			S.s1:	user-segment matrix with sigma = 1 (true segments)
%			S.s0:	user-segment matrix with sigma = 0 (false segments)
%		pre_data.V:
%			V.v1:	volume of true segments
%			V.v0:	volume of false segments
%
%	setting:
%		setting.eta:	learning rate parameter
%		setting.iter:	# of epochs
%		setting.period:	sampling period (epochs)
%		setting.dense:	dense sampling interval (epochs)
%
%	mat_tIDs:	map: idx >> tID
%		


%% Argument validation
%
if( ~exist('map_tIDs','var') )
	map_tIDs = [];
end


%% K-fold cross-validation setting
%
if( isempty(map_tIDs) )	
	[k_idx] = get_K_fold_classifier_data_idx( data.S, K );
else
	[K_tIDs] = get_K_fold_task_partition( map_tIDs, K );
end


%% Save information
%
n_users = size(data.S.s1,1);
save_info = get_classifier_save_info( save_path, n_users, setting );
K_suffix = sprintf('__K_%d/',K);
save_root_dir = [save_info.prefix,K_suffix];
mkdir(save_info.save_path,save_root_dir);
save_root_path = [save_path,save_root_dir];


%% K-fold cross-validation
%
for k = 1:K

	% get k-fold train and test data
	if( isempty(map_tIDs) )
		[k_fold] = generate_K_fold_data( data, k_idx, k );
	else
		[k_fold] = generate_K_fold_partition( data, map_tIDs, K_tIDs, k );
	end

	% save directory
	k_suffix = sprintf('k_%d',k);
	mkdir(save_root_path,k_suffix);
	k_path = [save_root_path,k_suffix,'/'];

	% train classifier with k-fold train data
	CM_train_classifier( k_path, k_fold.train, setting );

	% test classifier with k-fold test data
	CM_test_classifier( k_path, k_fold.test, setting );

end

end