function [model_error] = compute_error( err, cl_err, data )

% RMSE
squared_sum = sum((data.V_i.*err).^2);
RMSE = sqrt(squared_sum/size(data.S_ui,2));

% volume precision & recall
fn_idx = (cl_err > 0.5);
fp_idx = (cl_err < -0.5);
tp_idx = logical(data.sigma) & ~fn_idx;

fn = sum(double(fn_idx));
fp = sum(double(fp_idx));
tp = sum(double(tp_idx));

fnv = double(fn_idx)*data.V_i';
fpv = double(fp_idx)*data.V_i';
tpv = double(tp_idx)*data.V_i';

% result
model_error.SE 		= squared_sum;
model_error.RMSE 	= RMSE;

% supervoxel-based
model_error.tp 		= tp;
model_error.fn 		= fn;
model_error.fp 		= fp;
model_error.s_CE 	= (fp + fn)/(tp + fn + fp);
model_error.s_prec = tp/(tp + fp);
model_error.s_rec  = tp/(tp + fn);

% voxel-based
model_error.tpv 	= tpv;
model_error.fnv 	= fnv;
model_error.fpv 	= fpv;
model_error.CE 		= (fpv + fnv)/(tpv + fnv + fpv);
model_error.v 		= sum(data.V_i);
model_error.v_prec = tpv/(tpv + fpv);
model_error.v_rec  = tpv/(tpv + fnv);

end