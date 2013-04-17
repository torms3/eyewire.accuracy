function [ERR_const,ERR_exp] = CM_compute_default_classifier_error( data )

th_const	= 0.2;
th_exp	 	= 0.2;

s 		= data.S_ui;
v 		= data.V_i;
sigma 	= data.sigma;

n = sum(s > 0.5,1);
m = sum(s > -0.5,1);
prob = n./m;
prediction_const = prob > th_const;
prediction_exp = prob > min(0.99,(exp(-0.16*m) + th_exp));

err_const = sigma - double(prediction_const);
err_exp = sigma - double(prediction_exp);

[ERR_const] = compute_error( err_const, err_const, data );
[ERR_exp] 	= compute_error( err_exp, err_exp, data );

end