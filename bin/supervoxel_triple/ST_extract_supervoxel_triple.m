function [ST,vST] = ST_extract_supervoxel_triple( DB_MAPs, include_tn )

	T 	= DB_MAPs.T;
	V 	= DB_MAPs.V;
	VOL = DB_MAPs.VOL;


	%% Argument vavlidation
	%
	if( ~exist('include_tn','var') )
		include_tn = false;
	end


	%% Cube-wise processing
	%
	ST 		= cell(T.Count,1);
	vST 	= cell(T.Count,1);
	tIDs 	= T.keys;
	for i = 1:T.Count

		tID = tIDs{i};
		tInfo = T(tID);
		fprintf('(%d/%d) tID=%d is now being processed...\n',i,T.Count,tID);

		chID 	= tInfo.chID;
		volInfo = VOL(chID);
		n_seg 	= volInfo.n_seg;

		% union, consensus, and seed of this cube
		c_seg = tInfo.consensus;
		u_seg = tInfo.union;
		s_seg = tInfo.seed;

		% supervoxel size
		seg_size = tInfo.seg_size;

		% number of true negative supervoxels for this cube
		tn = n_seg - numel(u_seg);

		% ignore seed supervoxels
		c_seg = setdiff(c_seg,s_seg);
		u_seg = setdiff(u_seg,s_seg);

		% array for tracing (m,n)
		votes = zeros(1,numel(u_seg));

		% sigma
		c_idx = ismember(u_seg,c_seg);
		sigma = zeros(1,numel(u_seg));
		sigma(c_idx) = 1;

		% whether or not super-users has intervened this cube
		hotspot = 0; % ?

		% triples
		vIDs = tInfo.vIDs;
		nv = numel(vIDs);
		assert(nv > 0);
		triples = zeros(nv,nv+1,2);
		vtriples = zeros(nv,nv+1,2);

		% for each segment
		m = 0;
		for j = 1:nv

			vID = vIDs(j);
			vInfo = V(vID);
			seg = vInfo.segs;

			% super-user specific processing should be here

			% update votes
			m = m + 1;
			idx = ismember(u_seg,seg);
			votes(idx) = votes(idx) + 1;

			% extract segment triples (m,n,sigma)
			for k = 1:numel(votes)

				n 	= votes(k);
				sig = sigma(k);

				triples(m,n+1,sig+1) = triples(m,n+1,sig+1) + 1;
				vtriples(m,n+1,sig+1) = vtriples(m,n+1,sig+1) + seg_size(k);

			end

			% batch processing of true negative supervoxels
			if( include_tn )
				triples(m,0+1,0+1) = triples(m,0+1,0+1) + tn;
			end

		end

		% fileName = sprintf('tID_%d.dat',tID);
		% dlmwrite([savePath fileName],triples);
		ST{i} = triples;
		vST{i} = vtriples;

	end

end