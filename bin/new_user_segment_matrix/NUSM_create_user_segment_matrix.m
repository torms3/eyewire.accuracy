function [data] = NUSM_create_user_segment_matrix( DB_MAPs )

	%% Configuration
	%
	skipV0 = false;
	skipSuperuser = true;
	printFreq = 3000;
	timeSeries = true;


	%% DB_MAPs
	%
	U = DB_MAPs.U;
	T = DB_MAPs.T;
	V = DB_MAPs.V;
	[hotIDs,superIDs] = get_VT_hotspots( V, T );


	%% Time-series processing
	%
	if( timeSeries )
		nBins = 10;
		% binMode = 'time';
		binMode = 'validation';		
		[vTimeIdx] = process_validation_timeseries( V, nBins, binMode );
	end


	%% User-cube matrix
	%
	tIDs = cell2mat(T.keys);	% column
	uIDs = cell2mat(U.keys)';	% transpose: row

	nCube = numel(tIDs);
	nUser = numel(uIDs);
	

	%% Cube-wise pre-processing
	%
	seed = cell(1,nCube);
	sigma = cell(1,nCube);
	segIdx = cell(1,nCube);
	segSize = cell(1,nCube);
	scaffold = cell(1,nCube);
	map_tIDs = cell(1,nCube);
	for i = 1:nCube

		tID = tIDs(i);
		tInfo = T(tID);

		% assign a part of user-segment matrix corresponding to the current cube
		uSeg = tInfo.union;
		cSeg = tInfo.consensus;
		seed{i} = ismember(uSeg,tInfo.seed);
		sigma{i} = ismember(uSeg,cSeg);		
		segIdx{i} = uSeg;
		segSize{i} = tInfo.seg_size;
		scaffold{i} = zeros(nUser,numel(uSeg));
		map_tIDs{i} = tID*ones(1,numel(uSeg));

	end


	%% Validation-wise processing
	%
	vIDs = cell2mat(V.keys);
	nv = numel(vIDs);
	for i = 1:nv

		vID = vIDs(i);
		vInfo = V(vID);
		if( skipV0 & (vInfo.weight == 0) )
			continue;
		end
		if( skipSuperuser & (vInfo.weight > 1) )
			continue;
		end
		if( mod(i,printFreq) == 0 )
			fprintf('(%d/%d) %dth validation is now being processed...\n',i,nv,i);
		end

		col = find(tIDs==vInfo.tID);
		row = find(uIDs==vInfo.uID);

		M = scaffold{col};		
		idx = segIdx{col};
		voted = ismember(idx,sort(vInfo.segs,'ascend'));		
		if( timeSeries )
			M(row,:) = -vTimeIdx(i);
			M(row,voted) = vTimeIdx(i);
		else
			M(row,:) = 0;
			M(row,voted) = 1;
		end		
		scaffold{col} = M;

	end


	%% Return data
	%	
	data.tIDs = tIDs;
	data.uIDs = uIDs;
	data.map_tIDs = cell2mat(map_tIDs);
	data.seed = cell2mat(seed);
	data.sigma = cell2mat(sigma);
	data.segSize = cell2mat(segSize);
	data.matrix = cell2mat(scaffold);
	
	% hotspot & superuser info.
	data.hotIDs = hotIDs;
	data.superIDs = superIDs;

	% timeseries
	data.nBins = nBins;

end