function [data] = NUSM_create_user_segment_matrix( DB_MAPs )

	%% DB_MAPs
	%
	U = DB_MAPs.U;
	T = DB_MAPs.T;
	V = DB_MAPs.V;


	%%
	%
	tIDs = cell2mat(T.keys);	% column
	uIDs = cell2mat(U.keys)';	% transpose: row

	nCube = numel(tIDs);
	nUser = numel(nUser);


	%% Cube-wise processing
	%
	sigma = cell(1,nCube);
	segIdx = cell(1,nCube);
	segSize = cell(1,nCube);
	scaffold = cell(1,nCube);
	for i = 1:nCube

		tID = tIDs(i);
		tInfo = T(tID);

		% assign a part of user-segment matrix corresponding to the current cube
		uSeg = tInfo.union;
		cSeg = tInfo.consensus;
		sigma{i} = ismember(uSeg,cSeg);
		segIdx{i} = uSeg;
		segSize{i} = tInfo.seg_size;
		scaffold{i} = -ones(nUser,numel(uSeg));

	end


	%% Temporary
	%
	data.sigma = sigma;
	data.segIdx = segIdx;
	data.segSize = segSize;
	data.scaffold = scaffold;

end