function [ERR] = NUSM_compute_error_over_time( data )

	%% Configuration
	%
	seed = false;


	%% Seed consideration
	%
	if( ~seed )
		data.matrix(:,data.seed) = [];
		data.segSize(:,data.seed) = [];
		data.sigma(:,data.seed) = [];
	end


	% Data wrapper
	%	
	DW.V_i = data.segSize;
	DW.sigma = data.sigma;

	%% Timeseries
	%
	ERR = cell(data.nBins,1);
	for i = 1:data.nBins
		
		fprintf('(%d/%d) %dth time series is now being processed...\n',i,data.nBins,i);

		DW.S_ui = data.matrix;
		mask = abs(data.matrix) > i;
		DW.S_ui(mask) = 0;

		ERR{i} = NUSM_compute_error( DW );

	end

end


function [ERR] = NUSM_compute_error( data )
	
	th_exp 	= 0.2;

	s 		= data.S_ui;
	v 		= data.V_i;
	sigma 	= data.sigma;

	n = sum(s > 0,1);
	m = sum(s ~= 0,1);
	prob = n./m;
	prediction_exp = prob > min(0.99,(exp(-0.16*m) + th_exp));
	
	err_exp = sigma - double(prediction_exp);
	[ERR_exp] = compute_error( err_exp, err_exp, data );

	ERR = ERR_exp;

end


