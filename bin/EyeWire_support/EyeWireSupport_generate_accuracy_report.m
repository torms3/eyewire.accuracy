function [stats] = EyeWireSupport_generate_accuracy_report( STAT, fname, minCube )

	% convert data to convenient form
	[stats,n] = EyeWireSupport_extract_accuracy_stats( STAT, minCube );

	% write data
	M = [stats.nv stats.v_fs stats.v_prec stats.v_rec stats.tpv stats.fnv stats.fpv];
	csvwrite(fname, M);

end