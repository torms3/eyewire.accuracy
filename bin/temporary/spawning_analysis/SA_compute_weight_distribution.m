function [w,vw,hotspot] = SA_compute_weight_distribution( DB_MAPs )

	T = DB_MAPs.T;
	V = DB_MAPs.V;


	%% Cube-wise processing
	%
	hotspot = false(T.Count,1);
	w = extractfield( cell2mat(T.values), 'weight' );
	vw = zeros(size(w)); % weight computed from validations

	keys 	= T.keys;
	for i = 1:T.Count

		tID = keys{i};
		tInfo = T(tID);

		vIDs = tInfo.vIDs;
		for j = 1:numel(vIDs)

			vID = vIDs(j);
			vInfo = V(vID);

			if( vInfo.weight < CONST.GrimReaper_thresh )
				vw(i) = vw(i) + vInfo.weight;
			else
				hotspot(i) = true;
			end

		end

	end


	%% Report
	%	
	disp(['w/vw equality: ' num2str(isequal(w(~hotspot),vw(~hotspot)))]);
	disp(['(' num2str(nnz(hotspot)) '/' num2str(T.Count) ') GrimReaper cubes']);
	disp(['Average weight per GrimReaper cube: ' num2str(mean(vw(hotspot)))]);
	disp(['Average weight per non-GrimReaper cube: ' num2str(mean(vw(~hotspot)))]);
	disp(['Average weight per cube: ' num2str(mean(vw)) ' (without GrimReaper validations)']);	

end