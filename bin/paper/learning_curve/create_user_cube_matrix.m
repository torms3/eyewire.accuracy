function [M] = create_user_cube_matrix( CW_STAT )

nv = extractfield( cell2mat(CW_STAT.values), 'nv' )';
nCube = max(nv);
nUser = CW_STAT.Count;

M = -ones(nUser,nCube,3);


%% User-wise processing
%
keys 	= CW_STAT.keys;
vals 	= CW_STAT.values;
for i = 1:CW_STAT.Count

	key = keys{i};
	fprintf('(%d/%d) uID=%d is processing...\n',i,CW_STAT.Count,key);

	val = vals{i};
	assert( nv(i) == val.nv );
	tpv = val.tpv;
	fnv = val.fnv;
	fpv = val.fpv;

	M(i,1:nv(i),1) = tpv;
	M(i,1:nv(i),2) = fnv;
	M(i,1:nv(i),3) = fpv;

end

end