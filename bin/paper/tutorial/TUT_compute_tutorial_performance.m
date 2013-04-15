function [uIDs,perf] = TUT_compute_tutorial_performance( TUT_STAT )

%% User-wise processing
%
idx 	= 0;
keys 	= TUT_STAT.keys;
vals 	= TUT_STAT.values;
for i = 1:TUT_STAT.Count

	uID = keys{i};
	fprintf('(%d / %d) user (ID=%d) is now processing...\n',i,TUT_STAT.Count,uID);
	uStat = vals{i};

	difficulty = extractfield( cell2mat(uStat), 'difficulty' );
	tpv = extractfield( cell2mat(uStat), 'tpv' );
	fnv = extractfield( cell2mat(uStat), 'fnv' );
	fpv = extractfield( cell2mat(uStat), 'fpv' );

	target = (difficulty == 0);
	if( nnz(target) < 9 )
		continue;
	end

	idx = idx + 1;	
	uIDs(idx) = uID;

	tpv = sum(tpv(target));
	fnv = sum(fnv(target));
	fpv = sum(fpv(target));

	prec = tpv/(tpv + fpv);
	rec  = tpv/(tpv + fnv);
	fs   = 2*(prec*rec)/(prec + rec);

	perf{idx}.tpv 	= tpv;
	perf{idx}.fnv 	= fnv;
	perf{idx}.fpv 	= fpv;
	perf{idx}.prec 	= prec;
	perf{idx}.rec 	= rec;
	perf{idx}.fs 	= fs;

end

end