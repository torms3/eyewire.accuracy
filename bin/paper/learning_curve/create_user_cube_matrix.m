function [M] = create_user_cube_matrix( CW_STAT, super_uIDs )
%% Argument description
%	
%	CW_STAT: cube-wise user stats
%


%% Options
%
exclude_hot = false;


nv = extractfield( cell2mat(CW_STAT.values), 'nv' )';
uID = cell2mat(CW_STAT.keys);
nCube = max(nv);
nUser = CW_STAT.Count;


%% User-cube matrix
%
%	M(:,:,1) for true positive
%	M(:,:,2) for false negative
%	M(:,:,3) for false positive
%	M(:,:,4) for hotspot
%
M = -ones(nUser,nCube,4);


%% User-wise processing
%
keys 	= CW_STAT.keys;
vals 	= CW_STAT.values;
for i = 1:CW_STAT.Count

	key = keys{i};
	fprintf('(%d/%d) uID=%d is processing...\n',i,CW_STAT.Count,key);

	if( any(super_uIDs == key) )
		continue;
	end

	val = vals{i};
	assert( nv(i) == val.nv );
	tpv = val.tpv;
	fnv = val.fnv;
	fpv = val.fpv;
	hot = val.hot;

	if( exclude_hot )
		idx = ~logical(hot);
	else
		idx = logical(ones(size(hot)));
	end
	tpv = tpv(idx);
	fnv = fnv(idx);
	fpv = fpv(idx);

	if( any(idx) )
		M(i,1:numel(tpv),1) = tpv;
		M(i,1:numel(fnv),2) = fnv;
		M(i,1:numel(fpv),3) = fpv;
		% M(i,1:nv(i),4) = hot;
	end

end


%% Exclude super-users
%
superIdx = ismember(uID,super_uIDs);
M(superIdx,:,:) = [];

end