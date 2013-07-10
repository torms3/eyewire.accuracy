function [weight,hotspot] = SA_compute_weight_distribution( DB_MAPs )

	T = DB_MAPs.T;
	V = DB_MAPs.V;


	%% Cube-wise processing
	%
	hotspot = false(T.Count,1);
	weight = zeros(T.Count,1);

	keys 	= T.keys;
	for i = 1:T.Count

		tID = keys{i};
		tInfo = T(tID);

		vIDs = tInfo.vIDs;
		for j = 1:numel(vIDs)

			vID = vIDs(j);
			vInfo = V(vID);

			if( vInfo.weight < CONST.GrimReaper_thresh )
				weight(i) = weight(i) + vInfo.weight;
			else
				hotspot(i) = true;
			end

		end

	end


	%% Compute average weight
	%
	disp(['Average weight per cube = ' num2str(mean(weight))]);
	disp(['Average weight per cube = ' num2str(mean(weight(~hotspot)))]);

end