function [stat] = NUSM_compute_user_accuracy( data, seed )

	%% Argument validation
	%
	if( ~exist('seed','var') )
		seed = false;
	end


	%% Data
	%
	idx = (data.uIDs == 1);	% remove superuser
	stat.uIDs = data.uIDs(~idx);

	M = data.matrix(~idx,:);
	sigma = data.sigma;
	segSize = data.segSize;

	% seed consideration
	if( ~seed )
		M(:,data.seed) = [];
		sigma(:,data.seed) = [];
		segSize(:,data.seed) = [];
	end

	
	%% Compute accuracy
	%	
	% true positive	
	S = (M > 0);
	tp = S*double(sigma');
	tpv = S*(sigma.*segSize)';

	% false positive
	fp = S*double(~sigma');
	fpv = S*(~sigma.*segSize)';

	% false negative
	S = (M < 0);
	fn = S*double(sigma');
	fnv = S*(sigma.*segSize)';

	% true negative
	tn = S*double(~sigma');
	tnv = S*(~sigma.*segSize)';

	% accuracy
	sPrec = tp./(tp+fp);
	sRec = tp./(tp+fn);
	sFs = 2*sPrec.*sRec./(sPrec+sRec);

	vPrec = tpv./(tpv+fpv);
	vRec = tpv./(tpv+fnv);
	vFs = 2*vPrec.*vRec./(vPrec+vRec);


	%% User stat
	%
	stat.tp = tp;
	stat.fn = fn;
	stat.fp = fp;
	stat.tn = tn;
	
	stat.sPrec = sPrec;
	stat.sRec = sRec;
	stat.sFs = sFs;
	
	stat.tpv = tpv;
	stat.fnv = fnv;
	stat.fpv = fpv;
	stat.tnv = tnv;
	
	stat.vPrec = vPrec;
	stat.vRec = vRec;
	stat.vFs = vFs;

end