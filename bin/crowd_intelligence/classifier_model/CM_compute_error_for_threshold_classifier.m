function [ERR_const,ERR_exp] = CM_compute_error_for_threshold_classifier( data )

th_const	= 0.2;
th_exp	 	= 0.2;

s 		= data.S_ui;
v 		= data.V_i;
sigma 	= data.sigma;

n = sum(s > 0.5,1);
m = sum(s > -0.5,1);
prob = n./m;
prediction_const = prob > th_const;
prediction_exp = prob > (exp(-0.16*m) + th_exp);

err_const = sigma - double(prediction_const);
err_exp = sigma - double(prediction_exp);

[ERR_const] = compute_error( err_const, data );
[ERR_exp] = compute_error( err_exp, data );

end


function [CM_error] = compute_error( err, data )

% RMSE
RMSE = sqrt(sum((data.V_i.*err).^2)/size(data.S_ui,2));

% CE
CE = (abs(err)*data.V_i')/sum(data.V_i);

% volume precision & recall
fn_idx = (err > 0.5);
fp_idx = (err < -0.5);
tp_idx = logical(data.sigma) & ~fn_idx;

fnv = double(fn_idx)*data.V_i';
fpv = double(fp_idx)*data.V_i';
tpv = double(tp_idx)*data.V_i';

% result
CM_error.RMSE 	= RMSE;
CM_error.CE 	= CE;
CM_error.tpv 	= tpv;
CM_error.fnv 	= fnv;
CM_error.fpv 	= fpv;
CM_error.v_prec = tpv/(tpv + fpv);
CM_error.v_rec  = tpv/(tpv + fnv);

end