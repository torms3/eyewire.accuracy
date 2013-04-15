function [prec,rec,fs,hot] = compute_windowed_accuracy( uStat, idx )

	hot = sum(uStat.hot(idx));

	tpv = sum(uStat.tpv(idx));
	fnv = sum(uStat.fnv(idx));
	fpv = sum(uStat.fpv(idx));

	% precision
	prec = tpv/(tpv + fpv);
	if( isnan(prec) )
		prec = 0;
	end

	% recall
	rec = tpv/(tpv + fnv);
	if( isnan(rec) )
		rec = 0;
	end

	% f-measure
	fs = 2*(prec*rec)/(prec + rec);
	if( isnan(fs) )
		fs = 0;
	end

end