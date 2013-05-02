function [params] = extract_vanilla_parameters( data, param_type )

	%% Argument validation
	%
	if( ~exist('param_type','var') )
		param_type = 'supervoxel';
	end


	S_ui 	= data.S_ui;
	V_i 	= data.V_i;
	sigma 	= data.sigma;

	tv = sigma.*V_i;		% voxels for true segments
	fv = (~sigma).*V_i;		% voxels for false segments

	switch( param_type )
	case 'supervoxel'	% supervoxel-based

		tp = (S_ui == 1)*sigma';
		fn = (S_ui == 0)*sigma';
		fp = (S_ui == 1)*double(~sigma)';
		tn = (S_ui == 0)*double(~sigma)';
		
		s_prec = tp./(tp + fp);
		s_rec = tp./(tp + fn);
		
		s_p1 = s_rec;
		s_p0 = tn./(tn + fp);
		
		params.a = log((s_p1.*s_p0)./((1 - s_p1).*(1 - s_p0)));
		params.b = log((1 - s_p1)./s_p0);
		
	case 'voxel' 	% voxel-based

		tpv = (S_ui == 1)*tv';
		fnv = (S_ui == 0)*tv';
		fpv = (S_ui == 1)*fv';
		tnv = (S_ui == 0)*fv';

		v_prec = tpv./(tpv + fpv);
		v_rec = tpv./(tpv + fnv);

		v_p1 = v_rec;
		v_p0 = tnv./(tnv + fpv);

		params.a = log((v_p1.*v_p0)./((1 - v_p1).*(1 - v_p0)));
		params.b = log((1 - v_p1)./v_p0);

	otherwise
		assert( false );
		
	end


	%% [05/02/2013 kisuklee] TODO:
	% 
	%	NaN, Inf manipulation
	%
	params.a(isnan(params.a)) = 0;
	params.b(isnan(params.b)) = 0;

	epsilonInf = 1.0;
	params.a(isinf(params.a)) = epsilonInf*sign(params.a(isinf(params.a)));
	params.b(isinf(params.b)) = epsilonInf*sign(params.b(isinf(params.b)));
	% params.a(isinf(params.a)) = 0;
	% params.b(isinf(params.b)) = 0;

end