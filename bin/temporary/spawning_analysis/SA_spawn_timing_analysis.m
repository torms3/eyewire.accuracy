function [sp] = SA_spawn_timing_analysis( DB_MAPs )

	% spawning weight
	extract_child_info( DB_MAPs.T );
	extract_parent_info( DB_MAPs.T );
	extract_spawn_info( DB_MAPs );
	sp = extractfield( cell2mat(DB_MAPs.T.values), 'spawn' );
	sp(sp<0) = -sp(sp<0);
	hist(sp,min(sp):max(sp));

	
	created = extractfield( cell2mat(DB_MAPs.T.values), 'datenum' );
	created(1) = [];	% exclude the seed cube
	created = created/norm(created); % normalize

	% spawning timimg
	figure;
	hold on;
	for i = min(sp):max(sp)		

		idx = (sp == i);
		sub = created(idx);

		scatter(repmat(i,numel(sub),1),sub,30,'o');

	end
	hold off;

end