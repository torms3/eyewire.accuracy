function [uIDs,perf] = compute_windowed_EyeWire_accuracy( STAT, lidx )

lidx = unique(lidx);
max_lidx = max(lidx);


%% User-wise processing
%
idx = 0;
keys 	= STAT.keys;
vals 	= STAT.values;
for i = 1:STAT.Count

	uID = keys{i};
	fprintf('(%d / %d) user (ID=%d) is now processing...\n',i,STAT.Count,uID);
	uStat = vals{i};

	if( uStat.nv < max_lidx )
		continue;
	end

	idx = idx + 1;	
	uIDs(idx) = uID;

	tpv = sum(uStat.tpv(lidx));
	fnv = sum(uStat.fnv(lidx));
	fpv = sum(uStat.fpv(lidx));
	
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