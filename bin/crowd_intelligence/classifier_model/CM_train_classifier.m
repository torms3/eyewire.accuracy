function CM_train_classifier( save_path, pre_data, setting )
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
params 		= initialize_classifier_parameters( data.n_users, setting );
save_info 	= get_classifier_save_info( save_path, params.n_users, setting );


%% Iteration
%
tic

% global valid index
IDX = data.S_ui > -1;

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
	W 		= params.w;
	THETA 	= params.theta;	

	% get randomly permuted iteration indices for segments
	rand_idx = randperm(n_items);
	% rand_idx = 1:n_items;

	% iterate through whole segments
	for i = 1:n_items

		j 		= rand_idx(i);
		idx 	= IDX(:,j);
		
		% avoid repeated index referencing		
		s 		= S(idx,j);
		v 		= V(j);
		w 		= W(idx);
		theta 	= THETA(idx);
		

		% logistic function inlining
		SUM = sum((w.*s) - theta);		% default model
		% SUM = w'*(s - theta);			% nonnegativity model
		o = 1.0./(1.0 + exp(-SUM));
		
		% error
		err = sigma(j) - o;
		
		% update
		% common = eta*v*o*(1-o)*err;	% linear dependence on volume
		common = eta*o*(1-o)*err;
		% common = eta*err;

		W(idx) 		= w + (s.*common);
		THETA(idx) 	= theta - common;

		% nonnegativity constraints
		% W(idx) 		= max(0,w + ((s - theta).*common));	% (w >= 0)
		% W(idx) 		= min(1,max(0,w + ((s - theta).*common)));	% (w >= 0)
		% THETA(idx) 	= min(1,max(0,theta - w*common));	% (theta >= 0) and (theta <=1)

	end
	
	% write local parameters back
	params.w 		= W;
	params.theta 	= THETA;	

	params.epoch_time(epoch) = toc;
	fprintf('\n%dth epoch: iteration time=%f\n',epoch,params.epoch_time(epoch));

	% RMSE & CE (should decrease)
	if( epoch == params.sample_epoch(sample_cnt) )

		tic		
		
		[CM_error] = CM_compute_classifier_error( data, params );
		params.error{sample_cnt} = CM_error;
		% params.RMSE(sample_cnt) = CM_error.RMSE;
		% params.CE(sample_cnt) 	= CM_error.CE;
		% params.tpv(sample_cnt) 	= CM_error.tpv;
		% params.fnv(sample_cnt) 	= CM_error.fnv;
		% params.fpv(sample_cnt) 	= CM_error.fpv;
		
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


%% Plot learning curve
%
% plot_learning_curve( params );

end


function plot_learning_curve( params )

figure();

% RMSE
subplot(1,2,1);
plot(params.sample_epoch,params.RMSE);
xlabel('epochs');
ylabel('RMSE');
grid on;
grid minor;

% CE
subplot(1,2,2);
plot(params.sample_epoch,params.CE);
xlabel('epochs');
ylabel('CE');
grid on;
grid minor;

end