function [PM_error] = PM_compute_classifier_error( data, params )

%% Compute RMSE and CE
%
S = data.S_ui;
v = data.V_i;
IDX = (S > -1);
prior = data.prior;
n_items = numel(v);

A = params.a*ones(1,n_items);
B = params.b*ones(1,n_items);

SUM = sum(IDX.*(A.*S + B));			% default model
SUM = SUM + prior;
prediction = 1.0./(1.0 + exp(-SUM));

% RMSE
err 	= data.sigma - prediction;
cl_err 	= data.sigma - double(prediction > 0.5);	% classification error

% compute error
[PM_error] = compute_error( err, cl_err, data );

end