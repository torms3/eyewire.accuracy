function [params] = NCM_initialize_classifier_parameters( uIDs, setting, param )
%% Argument description
%
%	setting:
%		setting.eta:	learning rate parameter
%		setting.iter:	# of epochs
%		setting.period:	sampling period (epochs)
%		setting.dense:	dense sampling interval (epochs)
%

nUser = numel(uIDs);

%% Parameter initialization
%
% w, theta
epsilon_w 		= 0.01;
epsilon_theta 	= 0.01;
params.nUser	= nUser;
params.w 		= rand(nUser,1)*epsilon_w;
params.theta	= rand(nUser,1)*epsilon_theta;

if( exist('param','var') )	
	for i = 1:nUser
		uID = uIDs(i);
		if( isKey(param,uID) )
			idx = find(uIDs == uID);
			val = param(uID);
			params.w(idx) = val.w;
			params.theta(idx) = val.theta;
		end
	end
end

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