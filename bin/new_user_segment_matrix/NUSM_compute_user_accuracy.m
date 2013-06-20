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
	IDX = (M == 1);
	S = IDX.*M;
	tpv = S*(sigma.*segSize)';	% true positive
	fpv = S*(~sigma.*segSize)';	% false positive

	IDX = (M == 0);
	S = IDX.*M;
	fnv = S*(sigma.*segSize)';	% false negative

	prec = tpv./(tpv+fpv);
	rec = tpv./(tpv+fnv);
	fs = 2*prec.*rec./(prec+rec);


	%% User stat
	%
	stat.uIDs = data.uIDs;
	stat.tpv = tpv;
	stat.fnv = fnv;
	stat.fpv = fpv;
	stat.prec = prec;
	stat.rec = rec;
	stat.fs = fs;

end