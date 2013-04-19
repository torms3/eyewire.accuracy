function [CM_error] = CM_compute_classifier_error( data, params )

%% Compute RMSE and CE
%
S = data.S_ui;
v = data.V_i;
IDX = (S > -1);
n_items = numel(v);

W 		= params.w*ones(1,n_items);
THETA 	= params.theta*ones(1,n_items);

% SUM = sum(IDX.*(W.*S - THETA));			% default model
SUM = sum(IDX.*(W.*(S - THETA)),1);		% nonnegativity model
prediction = 1.0./(1.0 + exp(-SUM));

% RMSE
err 	= data.sigma - prediction;
cl_err 	= data.sigma - double(prediction > 0.5);	% classification error

% compute error
[CM_error] = compute_error( err, cl_err, data );

end