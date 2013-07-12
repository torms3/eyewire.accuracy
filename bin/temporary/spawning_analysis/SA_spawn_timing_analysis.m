function [sp] = SA_spawn_timing_analysis( DB_MAPs )

	% spawning weight
	extract_child_info( DB_MAPs.T );
	extract_parent_info( DB_MAPs.T );
	extract_spawn_info( DB_MAPs );
	sp = extractfield( cell2mat(DB_MAPs.T.values), 'spawn' );
	sp(sp<0) = -sp(sp<0);
	hist(sp,min(sp):max(sp));

	% spawning timimg
	% figure;
	% vals = DB_MAPs.T.values;
	% stat = zeros(numel(unique(sp)),1);	
	% for i = min(sp):max(sp)

	% 	created = extractfield( cell2mat(vals), 'datenum' );
	% 	created(1) = [];	% exclude the seed cube

	% 	idx = (sp == i);
	% 	created = created(idx);

	% 	stat(i-min(sp)+1) = quantile(created,0.5);

	% end	

end