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


%% Figures
%
figure;
h1 = gca;
figure;
h2 = gca;
figure;
h3 = gca;


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
Beta	= 3.3;

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
		o = 1.0./(1.0 + exp(-params.beta*u));
		
		% error
		err = sigma(j) - o;
		
		% update
		% THETA(m) = max(0,min(0.99,theta - eta*o*(1-o)*err));
		THETA(m) = max(0,min(0.99,theta - eta*err));

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
		fprintf('%dth epoch: SE = \t%f\n',epoch,CM_error.SE);
		fprintf('%dth epoch: CE = \t%f\n',epoch,CM_error.CE);
		fprintf('%dth epoch: v_prec = \t%f\n',epoch,CM_error.tpv/(CM_error.tpv+CM_error.fpv));
		fprintf('%dth epoch: v_rec = \t%f\n',epoch,CM_error.tpv/(CM_error.tpv+CM_error.fnv));

		x = params.sample_epoch(1:sample_cnt);
		y = extractfield( cell2mat(params.error(1:sample_cnt)), 'SE' );
		plot_learning_curve( h1, x, y );
		y = extractfield( cell2mat(params.error(1:sample_cnt)), 's_CE' );
		plot_learning_curve( h2, x, y );
		plot_parameters( h3, params );

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
epsilon_theta 	= 0.01;
params.n_users	= data.n_users;
% params.theta 	= theta.*epsilon_theta.*rand(size(theta));
params.theta 	= exp(-0.16*(1:max(m))) + 0.2;
params.th_idx	= th_idx;
params.beta 	= 3.3;

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


function plot_learning_curve( h, x, y )

% CE
plot(h,x,y);
xlabel(h,'epochs');
grid(h,'on');
grid(h,'minor');

drawnow

end


function plot_parameters( h, params )

x = 1:numel(params.theta);
y = exp(-0.16*x) + 0.2;
plot(h,x,y,'-r');
hold(h,'on');
scatter(h,x,params.theta);
hold(h,'off');
grid(h,'on');
grid(h,'minor');

drawnow

end