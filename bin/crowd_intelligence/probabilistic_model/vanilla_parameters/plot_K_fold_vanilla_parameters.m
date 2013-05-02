function plot_K_fold_vanilla_parameters( savePath, K )

	fileName = sprintf('vanilla_error__%d_',K);
	fileList = dir([savePath '/' fileName '*']);
	nFile = numel(fileList);
	assert( K == nFile );

	% error data structure
	expThresh.CE	= zeros(K,1);
	expThresh.prec	= zeros(K,1);
	expThresh.rec 	= zeros(K,1);
	expThresh.tpv 	= zeros(K,1);
	expThresh.fnv 	= zeros(K,1);
	expThresh.fpv 	= zeros(K,1);

	vanilla.CE		= zeros(K,1);
	vanilla.prec	= zeros(K,1);
	vanilla.rec 	= zeros(K,1);
	vanilla.tpv 	= zeros(K,1);
	vanilla.fnv 	= zeros(K,1);
	vanilla.fpv 	= zeros(K,1);

	for k = 1:K

		load([savePath '/' fileList(k).name]);
		
		% error for exponential threshold 
		expThresh.CE(k)		= ERR_exp.CE;
		expThresh.prec(k)	= ERR_exp.v_prec;
		expThresh.rec(k)	= ERR_exp.v_rec;
		expThresh.tpv(k) 	= ERR_exp.tpv;
		expThresh.fnv(k) 	= ERR_exp.fnv;
		expThresh.fpv(k) 	= ERR_exp.fpv;

		% error for vanilla parameters
		vanilla.CE(k)	= PM_error.CE;
		vanilla.prec(k)	= PM_error.v_prec;
		vanilla.rec(k)	= PM_error.v_rec;
		vanilla.tpv(k) 	= PM_error.tpv;
		vanilla.fnv(k) 	= PM_error.fnv;
		vanilla.fpv(k) 	= PM_error.fpv;

	end


	plot_error( expThresh, vanilla );

end


function plot_error( expThresh, vanilla )

	figure;

	CE = zeros(2,2);

	% exponential threshold
	% tpv = sum(expThresh.tpv);
	% fnv = sum(expThresh.fnv);
	% fpv = sum(expThresh.fpv);
	% CE(1,1) = (fnv + fpv)/(tpv + fnv + fpv);
	CE(1,1) = mean(expThresh.CE);

	% vanilla parameters
	% tpv = sum(vanilla.tpv);
	% fnv = sum(vanilla.fnv);
	% fpv = sum(vanilla.fpv);
	% CE(1,2) = (fnv + fpv)/(tpv + fnv + fpv);
	CE(1,2) = mean(vanilla.CE);
	
	bar(CE);
	disp(CE);

end