function PM_test_classifier( save_path, pre_data, setting )
%% Argument description
%
%	save_path
%
%	pre_data:
%		pre_data.S_ui
%		pre_data.V_i
%		pre_data.sigma
%		pre_data.map_i_tID
%
%	setting:
%		setting.eta:	learning rate parameter
%		setting.iter:	# of epochs
%		setting.period:	sampling period (epochs)
%		setting.dense:	dense sampling interval (epochs)


%% Parameter inititalization
%
data 		= PM_get_classifier_data( pre_data );
params 		= PM_initialize_classifier_parameters( data.n_users, setting );
save_info 	= get_classifier_save_info( save_path, params.n_users, setting );


%% Load
%
% get the list of params files
file_list = dir([save_path '/' 'params*']);

sample_epoch = params.sample_epoch;
n_samples = params.samples;
train_error = cell(1,n_samples);
for idx = 1:n_samples
	
	file_suffix = sprintf('_sample_%d.mat',sample_epoch(idx));
	load([save_path '/' save_info.prefix file_suffix]);
	
	[PM_error] 	= PM_compute_classifier_error( data, params );
	train_error{idx} = PM_error;
	
end

% error for threshold classifiers
[ERR_const,ERR_exp] = CM_compute_default_classifier_error( pre_data );

% test result
test_result.epochs 		= sample_epoch;
test_result.error 		= train_error;
test_result.ERR_const 	= ERR_const;
test_result.ERR_exp 	= ERR_exp;
save([save_path '/' 'test_result.mat'],'test_result');

end