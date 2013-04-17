function [CM_error] = compute_error( err, cl_err, data )

% RMSE
squared_sum = sum((data.V_i.*err).^2);
RMSE = sqrt(squared_sum/size(data.S_ui,2));

% volume precision & recall
fn_idx = (cl_err > 0.5);
fp_idx = (cl_err < -0.5);
tp_idx = logical(data.sigma) & ~fn_idx;

fnv = double(fn_idx)*data.V_i';
fpv = double(fp_idx)*data.V_i';
tpv = double(tp_idx)*data.V_i';

% CE
% CE = (fpv + fnv)/sum(data.V_i);
CE = (fpv + fnv)/(tpv + fnv + fpv);

% result
CM_error.SE 	= squared_sum;
CM_error.RMSE 	= RMSE;
CM_error.tpv 	= tpv;
CM_error.fnv 	= fnv;
CM_error.fpv 	= fpv;
CM_error.CE 	= CE;
CM_error.v 		= sum(data.V_i);
CM_error.v_prec = tpv/(tpv + fpv);
CM_error.v_rec  = tpv/(tpv + fnv);

end