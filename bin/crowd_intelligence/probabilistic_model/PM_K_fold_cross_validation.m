function PM_K_fold_cross_validation( save_path, data, setting, K, partition_mode )
%% Argument description
%
%	save_path
%
%	data:
%		data.S_ui
%		data.V_i
%		data.sigma
%		data.map_i_tID
%
%	setting:
%		setting.eta:	learning rate parameter
%		setting.iter:	# of epochs
%		setting.period:	sampling period (epochs)
%		setting.dense:	dense sampling interval (epochs)


%% Argument validation
%
if( ~exist('partition_mode','var') )
	partition_mode = 'task';
end


%% Save information
%
n_users = size(data.S_ui,1);
save_info = get_classifier_save_info( save_path, n_users, setting );
K_suffix = sprintf('__K_%d',K);
save_root_dir = [save_info.prefix K_suffix];
mkdir(save_info.save_path,save_root_dir);
save_root_path = [save_path '/' save_root_dir];


%% K-fold cross-validation setting
%
switch( partition_mode )
case 'task'
	[k_partition] = get_K_fold_task_partition( data.map_i_tID, K );
case 'segment'
	[k_partition] = get_K_fold_segment_partition( data, K );
otherwise
	assert(false);
end
file_name = sprintf('%d_partitoin.mat',K);
save([save_root_path '/' file_name],'k_partition');


%% K-fold cross-validation
%
for k = 1:K

	% save directory
	k_suffix = sprintf('k_%d',k);
	mkdir(save_root_path,k_suffix);
	k_path = [save_root_path '/' k_suffix];

	% get k-fold train and test data
	[k_fold] = generate_K_fold_data( data, k_partition{k} );

	% train classifier with k-fold train data
	PM_train_classifier( k_path, k_fold.train, setting );

	% test classifier with k-fold test data
	PM_test_classifier( k_path, k_fold.test, setting );

end

end