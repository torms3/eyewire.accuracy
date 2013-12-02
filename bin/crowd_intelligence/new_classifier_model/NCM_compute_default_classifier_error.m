function [ERR_const,ERR_exp] = NCM_compute_default_classifier_error( data, celltype )

if( ~exist('celltype','var') )
	celltype = 'default';
end

switch( celltype )
case 'sac'
	a = 1.00;
	b = -0.320;
	c = 0.220;
otherwise
	a = 1.00;
	b = -0.160;
	c = 0.200;
end

s 		= data.matrix;
v 		= data.segSize;
sigma 	= data.sigma;

n = sum(s > 0.5,1);
m = sum(s ~= 0,1);
prob = n./m;
prediction_const = prob > c;
prediction_exp = prob > min(0.99,(a*exp(b*m) + c));

err_const = sigma - double(prediction_const);
err_exp = sigma - double(prediction_exp);

[ERR_const] = NCM_compute_error( err_const, err_const, data );
[ERR_exp] 	= NCM_compute_error( err_exp, err_exp, data );

end