function [AI_stat] = AI_compute_AI_stat( AI_MAP )

	tpv = sum(extractfield( cell2mat(AI_MAP.values), 'tpv' ));
	fnv = sum(extractfield( cell2mat(AI_MAP.values), 'fnv' ));
	fpv = sum(extractfield( cell2mat(AI_MAP.values), 'fpv' ));

	prec = tpv/(tpv+fpv);
	rec = tpv/(tpv+fnv);
	fs = 2*(prec*rec)/(prec+rec);

	AI_stat.prec = prec;
	AI_stat.rec = rec;
	AI_stat.fs = fs;

end