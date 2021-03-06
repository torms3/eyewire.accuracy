function PM_train_classifier( save_path, pre_data, setting )
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
data 		= PM_get_classifier_data( pre_data );
params 		= PM_initialize_classifier_parameters( data.n_users, setting );
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
prior 	= data.prior;

sample_cnt = 1;
for epoch = 1:iter

	tic

	% read parameters into local variables
	A = params.a;
	B = params.b;	

	% get randomly permuted iteration indices for segments
	rand_idx = randperm(n_items);
	% rand_idx = 1:n_items;

	% iterate through whole segments
	for i = 1:n_items

		j 		= rand_idx(i);
		idx 	= IDX(:,j);
		
		% avoid repeated index referencing		
		s = S(idx,j);
		v = V(j);
		p = prior(j);
		a = A(idx);
		b = B(idx);

		% logistic function inlining
		SUM = sum((a.*s) + b);		% default model
		SUM = SUM + p;				% prior
		o = 1.0./(1.0 + exp(-SUM));
		
		% error
		err = sigma(j) - o;
		
		% update
		common = eta*o*(1-o)*err;

		% default model
		A(idx) = a + (s.*common);
		B(idx) = b + common;

		% nonnegativity model
		A(idx) = a + (s.*common);
		B(idx) = min(0,b + common);

	end
	
	% write local parameters back
	params.a = A;
	params.b = B;	

	params.epoch_time(epoch) = toc;
	fprintf('\n%dth epoch: iteration time=%f\n',epoch,params.epoch_time(epoch));

	% RMSE & CE (should decrease)
	if( epoch == params.sample_epoch(sample_cnt) )

		tic		
		
		[PM_error] = PM_compute_classifier_error( data, params );
		params.error{sample_cnt} = PM_error;
		
		% save params
		file_suffix = sprintf('_sample_%d.mat',epoch);
		file_name = [save_info.prefix file_suffix];
		try
			save([save_path '/' file_name],'params');
		catch err
			disp(err);
		end

		error_calculation_time = toc;
		
		fprintf('%dth epoch: error calculation time=%f\n',epoch,error_calculation_time);
		fprintf('%dth epoch: RMSE = \t%f\n',epoch,PM_error.RMSE);
		fprintf('%dth epoch: CE = \t%f\n',epoch,PM_error.CE);
		fprintf('%dth epoch: v_prec = \t%f\n',epoch,PM_error.tpv/(PM_error.tpv+PM_error.fpv));
		fprintf('%dth epoch: v_rec = \t%f\n',epoch,PM_error.tpv/(PM_error.tpv+PM_error.fnv));

		sample_cnt = sample_cnt + 1;

	else

		fprintf('%dth epoch done.\n',epoch);

	end

end

finish_time = toc;
fprintf('total elapsed time=%f\n',finish_time);


%% Plot learning curve
%
plot_learning_curve( params );

end


function plot_learning_curve( params )

tpv = extractfield( cell2mat(params.error), 'tpv' );
fnv = extractfield( cell2mat(params.error), 'fnv' );
fpv = extractfield( cell2mat(params.error), 'fpv' );
CE  = extractfield( cell2mat(params.error), 'CE' );

prec = tpv./(tpv + fpv);
rec = tpv./(tpv + fnv);

figure();

% precision
subplot(2,2,1);
plot(params.sample_epoch,prec);
xlabel('Epochs');
ylabel('Precision');
grid on;
grid minor;

% recall
subplot(2,2,2);
plot(params.sample_epoch,rec);
xlabel('Epochs');
ylabel('Recall');
grid on;
grid minor;

% CE
subplot(2,2,3);
plot(params.sample_epoch,CE);
xlabel('epochs');
ylabel('Classification error');
grid on;
grid minor;

end