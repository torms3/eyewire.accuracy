function [STAT] = NUSM_convert_stat_to_STAT( stat )

	tp = num2cell(stat.tp)';
	fn = num2cell(stat.fn)';
	fp = num2cell(stat.fp)';
	tn = num2cell(stat.tn)';

	tpv = num2cell(stat.tpv)';
	fnv = num2cell(stat.fnv)';
	fpv = num2cell(stat.fpv)';
	tnv = num2cell(stat.tnv)';

	sPrec = num2cell(stat.sPrec)';
	sRec = num2cell(stat.sRec)';
	sFs = num2cell(stat.sFs)';

	vPrec = num2cell(stat.vPrec)';
	vRec = num2cell(stat.vRec)';
	vFs = num2cell(stat.vFs)';

	vals = struct(  'tp',tp,'fn',fn,'fp',fp,'tn',tn, ...
					'tpv',tpv,'fnv',fnv,'fpv',fpv,'tnv',tnv, ...
					'sPrec',sPrec,'sRec',sRec,'sFs',sFs, ...
					'vPrec',vPrec,'vRec',vRec,'vFs',vFs ...
				 );
	vals = mat2cell(vals,1,ones(1,numel(vals)));

	% create an user accuracy MAP for cell_IDs
	keys  = num2cell(stat.uIDs);
	STAT = containers.Map( keys, vals );

	% remove superuser
	remove( STAT, num2cell([1]) );

end