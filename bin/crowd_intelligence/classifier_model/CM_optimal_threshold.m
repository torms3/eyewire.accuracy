function CM_optimal_threshold( save_path, pre_data, setting )
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


%% Data & parameter inititalization
%
data 		= get_classifier_data( pre_data );
params 		= initialize_threshold( data, setting );
save_info 	= get_classifier_save_info( save_path, params.n_users, setting );


%% Iteration
%
tic

% global valid index
IDX = data.S_ui > -1;
M = sum(IDX,1);

% avoid structure field referencing
iter 	= params.iter;
n_items	= data.n_items;
S		= data.S_ui;
V 		= data.V_i;
sigma 	= data.sigma;
eta		= params.eta;
period 	= params.period;

sample_cnt = 1;
for epoch = 1:iter

	tic

	% read parameters into local variables
	THETA 	= params.theta;	

	% get randomly permuted iteration indices for segments
	rand_idx = randperm(n_items);

	% iterate through whole segments
	for i = 1:n_items

		j 		= rand_idx(i);
		idx 	= IDX(:,j);
		m 		= M(j);
		theta 	= THETA(m);
		
		% avoid repeated index referencing		
		s 		= S(idx,j);
		v 		= V(j);

		% logistic function inlining
		u = sum(s)/m - theta;
		o = 1.0./(1.0 + exp(-u));
		
		% error
		err = sigma(j) - o;
		
		% update
		THETA(m) = max(0,min(0.99,theta - eta*v*o*(1-o)*err));

	end
	
	% write local parameters back
	params.theta 	= THETA;	

	params.epoch_time(epoch) = toc;
	fprintf('\n%dth epoch: iteration time=%f\n',epoch,params.epoch_time(epoch));

	% RMSE & CE (should decrease)
	if( epoch == params.sample_epoch(sample_cnt) )

		tic		
		
		[CM_error] = CM_compute_threshold_classifier_error( data, params );
		params.error{sample_cnt} = CM_error;
		
		% save params
		file_suffix = sprintf('_sample_%d.mat',epoch);
		file_name = [save_info.prefix,file_suffix];
		try
			save([save_path,file_name],'params');
		catch err
			disp(err);
		end

		error_calculation_time = toc;
		
		fprintf('%dth epoch: error calculation time=%f\n',epoch,error_calculation_time);
		fprintf('%dth epoch: RMSE = \t%f\n',epoch,CM_error.RMSE);
		fprintf('%dth epoch: CE = \t%f\n',epoch,CM_error.CE);
		fprintf('%dth epoch: v_prec = \t%f\n',epoch,CM_error.tpv/(CM_error.tpv+CM_error.fpv));
		fprintf('%dth epoch: v_rec = \t%f\n',epoch,CM_error.tpv/(CM_error.tpv+CM_error.fnv));

		sample_cnt = sample_cnt + 1;

	else

		fprintf('%dth epoch done.\n',epoch);

	end

end

finish_time = toc;
fprintf('total elapsed time=%f\n',finish_time);


end


function [params] = initialize_threshold( data, setting )

%% Parameter initialization
%
% data
valid_idx = data.S_ui > -1;
m = sum(valid_idx,1);
theta = zeros(1,max(m));
th_idx = unique(m);
theta(th_idx) = 1;

% theta
epsilon_theta 	= 0.99;
params.n_users	= data.n_users;
% params.theta	= theta.*rand(1,max(m))*epsilon_theta;
params.theta 	= theta*epsilon_theta;
params.th_idx	= th_idx;

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
params.error = cell(1,params.samples);

end