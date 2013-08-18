function [stats,n] = EyeWireSupport_extract_accuracy_stats( STAT, minCube )

	if( ~exist('minCube','var') )
		minCube = 1;
	end

	stats.username = extractfield( cell2mat(STAT.values), 'username' )';
	stats.nv = extractfield( cell2mat(STAT.values), 'nv' )';
	stats.tpv = extractfield( cell2mat(STAT.values), 'tpv' )';
	stats.fnv = extractfield( cell2mat(STAT.values), 'fnv' )';
	stats.fpv = extractfield( cell2mat(STAT.values), 'fpv' )';
	stats.v_prec = extractfield( cell2mat(STAT.values), 'v_prec' )';
	stats.v_rec = extractfield( cell2mat(STAT.values), 'v_rec' )';
	stats.v_fs = extractfield( cell2mat(STAT.values), 'v_fs' )';

	n = STAT.Count;

	if( minCube > 1 )
		nCubeFilter = stats.nv >= minCube;
		n = nnz(nCubeFilter);

		stats.username = stats.username(nCubeFilter);
		stats.nv = stats.nv(nCubeFilter);
		stats.tpv = stats.tpv(nCubeFilter);
		stats.fnv = stats.fnv(nCubeFilter);
		stats.fpv = stats.fpv(nCubeFilter);
		stats.v_prec = stats.v_prec(nCubeFilter);
		stats.v_rec = stats.v_rec(nCubeFilter);
		stats.v_fs = stats.v_fs(nCubeFilter);
	end

end