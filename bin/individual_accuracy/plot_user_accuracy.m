function [ret] = plot_user_accuracy( MAPs, w )

	V = MAPs.V;
	total.tpv = extractfield(cell2mat(V.values),'tpv');
	total.fnv = extractfield(cell2mat(V.values),'fnv');
	total.fpv = extractfield(cell2mat(V.values),'fpv');	
	total.sac = cell2mat(extractfield(cell2mat(V.values),'SAC'));

	if ~exist('w','var')
		w(1) = numel(total.sac);
		w(2) = nnz(total.sac);
		w(3) = w(1) - w(2);
	end

	%% SAC vs. non-SAC	
	SAC.tpv = total.tpv(logical(total.sac));
	SAC.fnv = total.fnv(logical(total.sac));
	SAC.fpv = total.fpv(logical(total.sac));
	nonSAC.tpv = total.tpv(~logical(total.sac));
	nonSAC.fnv = total.fnv(~logical(total.sac));
	nonSAC.fpv = total.fpv(~logical(total.sac));

	%% Moving accuracy
	total 	= moving_accuracy(total,w(1));
	SAC 	= moving_accuracy(SAC,w(2));
	nonSAC 	= moving_accuracy(nonSAC,w(3));
	
	%% Binned binned
	total 	= binned_accuracy(total,w(1));
	SAC 	= binned_accuracy(SAC,w(2));
	nonSAC 	= binned_accuracy(nonSAC,w(3));

	%% Precision, recall, f-score
	total 	= compute_accuracy(total);
	SAC 	= compute_accuracy(SAC);
	nonSAC 	= compute_accuracy(nonSAC);

	%% Plot
	% figure;
	% hold on;
	% plot(total.mprec,'-b');
	% plot(total.mrec,'-r');
	% plot(total.mfs,'-k');
	% hold off;
	% grid on;

	% figure;
	% hold on;
	% plot(total.bprec,'-b');
	% plot(total.brec,'-r');
	% plot(total.bfs,'-k');
	% hold off;
	% grid on;

	%% Return	
	ret.total 	= total;
	ret.SAC 	= SAC;
	ret.nonSAC  = nonSAC;

end


function [ret] = moving_accuracy( ret, w )

	% convolving filter
	f = ones(w,1);

	ret.mtpv = conv(ret.tpv,f,'valid');
	ret.mfnv = conv(ret.fnv,f,'valid');
	ret.mfpv = conv(ret.fpv,f,'valid');

end


function [ret] = binned_accuracy( ret, w )

	nsample = numel(ret.mtpv);
	nbin = floor(nsample/w);
	idx = flip(nsample:-w:1);
	
	ret.btpv = ret.mtpv(idx);
	ret.bfnv = ret.mfnv(idx);
	ret.bfpv = ret.mfpv(idx);

end


function [ret] = compute_accuracy( ret )

	ret.mprec = ret.mtpv./(ret.mtpv+ret.mfpv);
	ret.mrec  = ret.mtpv./(ret.mtpv+ret.mfnv);
	ret.mfs   = (2*ret.mprec.*ret.mrec)./(ret.mprec+ret.mrec);

	ret.bprec = ret.btpv./(ret.btpv+ret.bfpv);
	ret.brec  = ret.btpv./(ret.btpv+ret.bfnv);
	ret.bfs   = (2*ret.bprec.*ret.brec)./(ret.bprec+ret.brec);

end