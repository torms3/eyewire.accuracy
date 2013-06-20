function [ERR] = NUSM_compute_error( data, classifier )

	%% Configuration
	%
	hotspot = true;
	seed = false;


	%% Data wrapper
	%
	DW.S_ui = data.matrix;
	DW.V_i = data.segSize;
	DW.sigma = data.sigma;


	%% Seed consideration
	%
	if( ~seed )

		DW.S_ui(:,data.seed) = [];
		DW.V_i(:,data.seed) = [];
		DW.sigma(:,data.seed) = [];

	end


	%% Hotspot accuracy
	%
	if( hotspot )

		idx = ismember(data.map_tIDs,data.hotIDs);
		DW.S_ui = DW.S_ui(:,idx);
		DW.V_i = DW.V_i(:,idx);
		DW.sigma = DW.sigma(:,idx);

	end


	%% Compute error from the classifier
	%
	switch( classifier )
	case 'majority'
		[ERR_const,ERR_exp] = CM_compute_default_classifier_error( DW );
		ERR.const = ERR_const;
		ERR.exp = ERR_exp;
	otherwise
		assert( false );
	end

end