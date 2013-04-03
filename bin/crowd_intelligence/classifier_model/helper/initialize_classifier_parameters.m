function [params] = initialize_classifier_parameters( n_users, setting )
%% Argument description
%
%	setting:
%		setting.eta:	learning rate parameter
%		setting.iter:	# of epochs
%		setting.period:	sampling period (epochs)
%		setting.dense:	dense sampling interval (epochs)
%

%% Parameter initialization
%
% w, theta
epsilon_w 		= 0.01;
epsilon_theta 	= 0.01;
params.n_users	= n_users;
params.w 		= rand(n_users,1)*epsilon_w;
params.theta	= rand(n_users,1)*epsilon_theta;

% learning rate
params.eta = setting.eta;

% iterations
params.iter = setting.iter;
params.period = setting.period;

% periodic sampling interval
sample_idx = (mod((1:params.iter),params.period) == 0);
params.periodic_epoch = find(sample_idx);
params.periodic_samples = nnz(sample_idx);

% dense sampling interval (typically first 10 epochs)
params.dense_samples = setting.dense;
sample_idx(1:setting.dense) = 1;
params.sample_epoch = find(sample_idx);
params.samples = nnz(sample_idx);

% statistics
params.epoch_time = zeros(1,params.iter);

% params.RMSE = zeros(1,params.samples);
% params.CE = zeros(1,params.samples);
% params.tpv = zeros(1,params.samples);
% params.fnv = zeros(1,params.samples);
% params.fpv = zeros(1,params.samples);
params.error = cell(1,params.samples);

end