function [CM_error] = CM_compute_classifier_error( data, params )

%% Compute RMSE and CE
%
S = data.s;
v = data.v;
IDX = (S > -1);

W 		= params.w*ones(1,data.n_items);
THETA 	= params.theta*ones(1,data.n_items);

% SUM = sum(IDX.*(W.*S - THETA));			% default model
SUM = sum(IDX.*(W.*(S - THETA)),1);		% nonnegativity model
prediction = 1.0./(1.0 + exp(-SUM));

% RMSE
err = data.sigma - prediction;
squared_sum = sum((v.*err).^2);
RMSE = sqrt(squared_sum/data.n_items);

% CE
err = data.sigma - double(prediction > 0.5);

fn_idx = (err > 0.5);
fp_idx = (err < -0.5);
tp_idx = logical(data.sigma) & ~fn_idx;

fnv = double(fn_idx)*v';
fpv = double(fp_idx)*v';
tpv = double(tp_idx)*v';

% CE = (abs(err)*v')/(data.sigma*v');
% CE = (abs(err)*v')/sum(v);
CE = (fpv + fnv)/sum(v);

CM_error.SE 	= squared_sum;
CM_error.n 		= data.n_items;
CM_error.RMSE 	= RMSE;
CM_error.tpv 	= tpv;
CM_error.fnv 	= fnv;
CM_error.fpv 	= fpv;
CM_erorr.v 		= sum(v);
CM_error.CE 	= CE;

end