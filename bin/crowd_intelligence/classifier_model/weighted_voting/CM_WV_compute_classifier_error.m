function [CM_error] = CM_WV_compute_classifier_error( data, params )

%% Compute RMSE and CE
%
S = data.S_ui;
v = data.V_i;
IDX = (S > -1);
n_items = numel(v);

m = sum(IDX,1);
th_exp = 0.2;
th = min(0.99,(exp(-0.16*m) + th_exp));

W = params.w*ones(1,n_items);

% SUM = sum(IDX.*(W.*S - THETA));			% default model
SUM = sum(IDX.*(W.*S),1) - th;		% nonnegativity model
prediction = 1.0./(1.0 + exp(-SUM));

% RMSE
err 	= data.sigma - prediction;
cl_err 	= data.sigma - double(prediction > 0.5);	% classification error

% compute error
[CM_error] = compute_error( err, cl_err, data );

end