function [MAP_param,ret] = NCM_batch_script( dataPath, savePath, setting )

	if( ~exist('setting','var') )
		[setting] = CM_prepare_setting();
	end

	% configuration
	fileCount = 1;
	stopCount = 30;

	% DB_MAPs files are assuemd to be processed 
	% in an ascending order of cell numbers
	data_list = dir(dataPath);
	for i = 1:numel(data_list)

		% skip non-file
		if( data_list(i).isdir )
			continue;
		end

		% load file
		fileName = data_list(i).name;
		disp([fileName ' is now being processed...']);
		load([dataPath '/' fileName]);

		% extract user-segment matrix
		skipV0 = false;
		[data] = NUSM_create_user_segment_matrix( DB_MAPs, skipV0 );

		% test
		if( exist('MAP_param','var') )
			ret{fileCount}.fileName = fileName;
			
			[~,ERR_exp] = NCM_compute_default_classifier_error( data, 'sac' );
			ret{fileCount}.ERR_exp = ERR_exp;
			
			[data_param] = NCM_construct_data_param( data, MAP_param );
			[NCM_err] = NCM_compute_classifier_error( data, data_param );
			ret{fileCount}.NCM_err = NCM_err;

			[NCM_err] = NCM_compute_classifier_error( data, data_param, 0.3 );
			ret{fileCount}.NCM_err_30 = NCM_err;
			[NCM_err] = NCM_compute_classifier_error( data, data_param, 0.35 );
			ret{fileCount}.NCM_err_35 = NCM_err;
			[NCM_err] = NCM_compute_classifier_error( data, data_param, 0.4 );
			ret{fileCount}.NCM_err_40 = NCM_err;
			[NCM_err] = NCM_compute_classifier_error( data, data_param, 0.45 );
			ret{fileCount}.NCM_err_45 = NCM_err;
			[NCM_err] = NCM_compute_classifier_error( data, data_param, 0.55 );
			ret{fileCount}.NCM_err_55 = NCM_err;
			[NCM_err] = NCM_compute_classifier_error( data, data_param, 0.6 );
			ret{fileCount}.NCM_err_60 = NCM_err;

			skipV0 = true;
			[data_wo_v0] = NUSM_create_user_segment_matrix( DB_MAPs, skipV0 );
			[~,ERR_ref] = NCM_compute_default_classifier_error( data_wo_v0, 'sac' );
			ret{fileCount}.ERR_ref = ERR_ref;

			fileCount = fileCount + 1;
		end
		if( stopCount < fileCount )
			break;
		end

		% train
		if( ~exist('MAP_param','var') )
			[MAP_param] = NCM_train_classifier( savePath, data, setting );
		else
			[MAP_param] = NCM_train_classifier( savePath, data, setting, MAP_param );
		end

	end

end