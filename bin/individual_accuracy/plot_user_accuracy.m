function [ret] = plot_user_accuracy( MAPs, w )

	V = MAPs.V;
	tpv = extractfield(cell2mat(V.values),'tpv');
	fnv = extractfield(cell2mat(V.values),'fnv');
	fpv = extractfield(cell2mat(V.values),'fpv');

	%% Moving accuracy
	f = ones(w,1); 		% convolving filter
	mtpv = conv(tpv,f,'valid');
	mfnv = conv(fnv,f,'valid');
	mfpv = conv(fpv,f,'valid');

	%% Binned binned
	nsample = numel(mtpv);
	nbin = floor(nsample/w);
	idx = flip(nsample:-w:1);
	btpv = mtpv(idx);
	bfnv = mfnv(idx);
	bfpv = mfpv(idx);

	%% Precision, recall, f-score
	mprec = mtpv./(mtpv+mfpv);
	mrec  = mtpv./(mtpv+mfnv);
	mfs   = (2*mprec.*mrec)./(mprec+mrec);
	bprec = btpv./(btpv+bfpv);
	brec  = btpv./(btpv+bfnv);
	bfs   = (2*bprec.*brec)./(bprec+brec);

	%% Plot
	figure;
	hold on;
	plot(mprec,'-b');
	plot(mrec,'-r');
	plot(mfs,'-k');
	hold off;
	grid on;

	figure;
	hold on;
	plot(bprec,'-b');
	plot(brec,'-r');
	plot(bfs,'-k');
	hold off;
	grid on;

	%% Return	
	ret.mprec = mprec;
	ret.mrec = mrec;
	ret.mfs = mfs;
	ret.bprec = bprec;
	ret.brec = brec;
	ret.bfs = bfs;
	ret.w = w;

end