function K_fold_vanilla_parameters( savePath, data, data1, K )

	saveFile = 'vanilla_error';

	% K-fold cross-validation
	[k_partition] = get_K_fold_task_partition( data.map_i_tID, K );
	[k_partition1] = get_K_fold_task_partition( data1.map_i_tID, K );
	for k = 1:K

		fprintf('(%d/%d)-fold cross-validation...\n',k,K);

		% get k-fold train and test data
		[k_fold] = generate_K_fold_data( data, k_partition{k} );
		[k_fold1] = generate_K_fold_data( data1, k_partition1{k} );

		% extract vanilla parameters from test data
		fprintf('extracting vanilla parameters from train data...\n');
		[params] = extract_vanilla_parameters( k_fold.train, 'supervoxel' );
		[params1] = extract_vanilla_parameters( k_fold1.train, 'supervoxel' );

		% extract prior
		fprintf('extracting prior for test data...\n');
		[k_fold.test.prior] = extract_prior( k_fold.test, 'cube', 'supervoxel' );
		[k_fold1.test.prior] = extract_prior( k_fold1.test, 'cube', 'supervoxel' );		 

		% test generalization performance		
		[PM_error] = PM_compute_classifier_error( k_fold.test, params );
		[PM_error1] = PM_compute_classifier_error( k_fold1.test, params1 );

		% reference performance
		[~,ERR_exp] = CM_compute_default_classifier_error( k_fold.test );
		[~,ERR_exp1] = CM_compute_default_classifier_error( k_fold1.test );

		% save directory
		fprintf('saving test results...\n');
		k_suffix = sprintf('%d_%d',K,k);
		k_path = [savePath '/' saveFile '__' k_suffix '.mat'];
		save(k_path,'PM_error','ERR_exp','PM_error1','ERR_exp1');

	end

end