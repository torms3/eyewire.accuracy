function CM_WV_train_classifier( save_path, pre_data, setting )
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


%% Figures
%
figure;
h1 = gca;
figure;
h2 = gca;


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

M = sum(S > -0.5,1);
dEta = (0.999*eta)/iter;

sample_cnt = 1;
for epoch = 1:iter

	tic

	% decreasing the learning rate parameter eta
	eta = params.eta/epoch;

	% read parameters into local variables
	W = params.w;

	% get randomly permuted iteration indices for segments
	rand_idx = randperm(n_items);

	% iterate through whole segments
	for i = 1:n_items

		j 		= rand_idx(i);
		idx 	= IDX(:,j);
		
		% avoid repeated index referencing		
		s 		= S(idx,j);
		v 		= V(j);
		w 		= W(idx);
		m 		= M(j);
		thresh 	= exp(-0.16*m) + 0.2;		

		% logistic function inlining
		SUM = (w'*s)/m - thresh;		% default model
		% SUM = w'*(s - theta);			% nonnegativity model
		o = 1.0./(1.0 + exp(-SUM));
		
		% error
		err = sigma(j) - o;
		
		% update
		% common = eta*v*o*(1-o)*err;	% linear dependence on volume
		common 	= eta*o*(1-o)*err;
		% common = eta*err;

		% default model
		% W(idx) 	= w + (s.*common)/m;
		% nonnegativity constraints
		W(idx) 	= min(1,max(0,w + (s.*common)/m));	% (w >= 0) and (w <=1)

	end	

	% decreasing the learning rate parameter eta
	% eta = eta - dEta;
	
	% write local parameters back
	params.w 		= W;

	params.epoch_time(epoch) = toc;
	fprintf('\n%dth epoch: iteration time=%f\n',epoch,params.epoch_time(epoch));

	% RMSE & CE (should decrease)
	if( epoch == params.sample_epoch(sample_cnt) )

		tic		
		
		[CM_error] = CM_WV_compute_classifier_error( data, params );
		params.error{sample_cnt} = CM_error;;
		
		% save params
		file_suffix = sprintf('_sample_%d.mat',epoch);
		file_name = [save_info.prefix,file_suffix];
		try
			save([save_path '/' file_name],'params');
		catch err
			disp(err);
		end

		error_calculation_time = toc;
		
		fprintf('%dth epoch: error calculation time=%f\n',epoch,error_calculation_time);
		fprintf('%dth epoch: RMSE = \t%f\n',epoch,CM_error.RMSE);
		fprintf('%dth epoch: CE = \t%f\n',epoch,CM_error.CE);
		fprintf('%dth epoch: v_prec = \t%f\n',epoch,CM_error.tpv/(CM_error.tpv+CM_error.fpv));
		fprintf('%dth epoch: v_rec = \t%f\n',epoch,CM_error.tpv/(CM_error.tpv+CM_error.fnv));

		x = params.sample_epoch(1:sample_cnt);
		y = extractfield( cell2mat(params.error(1:sample_cnt)), 'CE' );
		plot_learning_curve( h1, x, y );
		plot_parameters( h2, params );

		sample_cnt = sample_cnt + 1;

	else

		fprintf('%dth epoch done.\n',epoch);

	end

end

finish_time = toc;
fprintf('total elapsed time=%f\n',finish_time);

end


function plot_learning_curve( h, x, y )

% CE
plot(h,x,y);
xlabel(h,'epochs');
ylabel(h,'CE');
grid(h,'on');
grid(h,'minor');

drawnow

end


function plot_parameters( h, params )

scatter(h,1:params.n_users,params.w);
xlabel(h,'user index');
ylabel(h,'w');
grid on;
grid minor;

drawnow

end