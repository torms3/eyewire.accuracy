function [CM_error] = CM_compute_threshold_classifier_error( data, params )

%% Compute RMSE and CE
%
S = data.S_ui;
v = data.V_i;
IDX = (S > -1);
m = sum(IDX,1);
th = params.theta;

disp(size(th));
th(unique(m)) = min(0.99,(exp(-0.16*unique(m)) + 0.2));
th = th';

U = (sum(IDX.*S,1)./m) - th(m);
prediction = 1.0./(1.0 + exp(-params.beta*U));

% RMSE
err 	= data.sigma - prediction;
cl_err 	= data.sigma - double(prediction > 0.5);	% classification error

% compute error
[CM_error] = compute_error( err, cl_err, data );

end