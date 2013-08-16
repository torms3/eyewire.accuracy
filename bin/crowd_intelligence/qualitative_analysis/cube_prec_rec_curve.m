function [] = cube_prec_rec_curve( DB_MAPs, idx )

	%% Argument validations
	%
	if( ~exist('idx','var') )
		idx = 1;
	end


	U = DB_MAPs.U;
	T = DB_MAPs.T;
	V = DB_MAPs.V;

	vals = T.values;
	tInfo = vals{idx};
	
	% consensus
	cSeg = tInfo.consensus;

	% accuracy info
	UA = cell(numel(tInfo.vIDs),1);
	for i = 1:numel(tInfo.vIDs)

		vID = tInfo.vIDs(i);
		vInfo = V(vID);

		% accuracy calculation
		includeSeed = false;
		[VA] = process_each_validation( vInfo, tInfo, includeSeed );

		% precision & recall
		UA{i}.prec = sum(VA.tp)/(sum(VA.tp) + sum(VA.fp));
		UA{i}.rec  = sum(VA.tp)/(sum(VA.tp) + sum(VA.fn));
		UA{i}.fs   = 2*UA{i}.prec*UA{i}.rec/(UA{i}.prec+UA{i}.rec);

	end


	%% Plot
	%
	figure();
	prec = extractfield( cell2mat(UA), 'prec' );
	rec  = extractfield( cell2mat(UA), 'rec' );

	scatter(rec,prec,'rx');

	% xlim([0.95 1.0]);
	% ylim([0.95 1.0]);

end