function [stat] = NUSM_compute_user_accuracy( data )

	%% Configuration
	%
	seed = false;


	%% Data
	%
	M = data.matrix;
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
	S = (M == 1);
	tp = S*(sigma');
	tpv = S*(sigma.*segSize)';

	% false positive
	fp = S*(~sigma');
	fpv = S*(~sigma.*segSize)';

	% false negative
	S = (M == 0);
	fn = S*(sigma');
	fnv = S*(sigma.*segSize)';

	% true negative
	tn = S*(~sigma');
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
	stat.uIDs = data.uIDs;
	stat.tp = tp;
	stat.fn = fn;
	stat.fp = fp;
	stat.tn = tn;
	stat.tpv = tpv;
	stat.fnv = fnv;
	stat.fpv = fpv;
	stat.tnv = tnv;
	stat.prec = prec;
	stat.rec = rec;
	stat.fs = fs;

end