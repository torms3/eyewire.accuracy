function [MAP_param] = NCM_train_classifier( savePath, data, setting, MAP_param )
%% Argument description
%
%	savePath
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


% data matrix
M = data.matrix;
[nUser,nItem] = size(M);


%% Data & parameter inititalization
%
if( exist('MAP_param','var') )
	params	= NCM_initialize_classifier_parameters( data.uIDs, setting, MAP_param );
else
	params	= NCM_initialize_classifier_parameters( data.uIDs, setting );
end
saveInfo 	= get_classifier_save_info( savePath, nUser, setting );


%% Iteration
%
% global valid index
IDX = (M ~= 0);
M(M == -1) = 0;

% avoid structure field referencing
iter 	= params.iter;
V 		= data.segSize;
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
	rand_idx = randperm(nItem);
	% rand_idx = 1:nItem;

	% iterate through whole segments
	for ii = 1:nItem

		i 		= rand_idx(ii);
		idx 	= IDX(:,i);
		
		% avoid repeated index referencing		
		s 		= M(idx,i);
		v 		= V(i);
		w 		= W(idx);
		theta 	= THETA(idx);
				
		SUM = sum((w.*s) - theta);		% default model
		% SUM = w'*(s - theta);			% nonnegativity model
		o = 1.0./(1.0 + exp(-SUM));		% logistic function inlining
		
		% error
		err = sigma(i) - o;
		
		% update
		% common = eta*v*o*(1-o)*err;	% linear dependence on volume
		common = eta*o*(1-o)*err;
		% common = eta*err;

		W(idx) 		= w + (s.*common);
		THETA(idx) 	= theta - common;

		% nonnegativity constraints
		% W(idx) 		= max(0,w + ((s - theta).*common));	% (w >= 0)
		% W(idx) 		= min(1,max(0,w + ((s - theta).*common)));	% (w >= 0) and (w <= 1)
		% THETA(idx) 	= min(1,max(0,theta - w*common));	% (theta >= 0) and (theta <=1)

	end

	% annealing
	eta = eta*0.99;
	
	% write local parameters back
	params.w 		= W;
	params.theta 	= THETA;	

	params.epoch_time(epoch) = toc;
	fprintf('\n%dth epoch: iteration time=%f\n',epoch,params.epoch_time(epoch));

	% RMSE & CE (should decrease)
	if( epoch == params.sample_epoch(sample_cnt) )

		tic		
		
		[NCM_error] = NCM_compute_classifier_error( data, params );
		params.error{sample_cnt} = NCM_error;
		
		% save params
		file_suffix = sprintf('_sample_%d.mat',epoch);
		file_name = [saveInfo.prefix,file_suffix];
		try
			save([savePath '/' file_name],'params');
		catch err
			disp(err);
		end

		error_calculation_time = toc;
		
		fprintf('%dth epoch: error calculation time=%f\n',epoch,error_calculation_time);
		fprintf('%dth epoch: RMSE = \t%f\n',epoch,NCM_error.RMSE);
		fprintf('%dth epoch: CE = \t%f\n',epoch,NCM_error.CE);
		% fprintf('%dth epoch: v_prec = \t%f\n',epoch,NCM_error.tpv/(NCM_error.tpv+NCM_error.fpv));
		% fprintf('%dth epoch: v_rec = \t%f\n',epoch,NCM_error.tpv/(NCM_error.tpv+NCM_error.fnv));

		sample_cnt = sample_cnt + 1;

	else

		fprintf('%dth epoch done.\n',epoch);

	end

end

%% MAP_param update
%
if( ~exist('MAP_param','var') )
	keys = num2cell(data.uIDs);
	for i = 1:nUser
		vals{i}.w = params.w(i);
		vals{i}.theta = params.theta(i);
	end
	MAP_param = containers.Map( keys, vals );
else
	for i = 1:nUser
		uID = data.uIDs(i);
		idx = find(data.uIDs == uID);
		val.w = params.w(idx);
		val.theta = params.theta(idx);
		MAP_param(uID) = val;
	end
end



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