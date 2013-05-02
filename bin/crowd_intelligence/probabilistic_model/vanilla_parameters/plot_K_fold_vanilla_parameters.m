function plot_K_fold_vanilla_parameters( savePath, K )

	fileName = sprintf('vanilla_error__%d_',K);
	fileList = dir([savePath '/' fileName '*']);
	nFile = numel(fileList);
	assert( K == nFile );

	% error data structure
	expThresh 	= cell(K,1);
	expThresh1 	= cell(K,1);
	vanilla 	= cell(K,1);
	vanilla1 	= cell(K,1);

	% error data structure
	for k = 1:K

		load([savePath '/' fileList(k).name]);
		
		% error for exponential threshold
		expThresh{k} 	= ERR_exp;
		expThresh1{k} 	= ERR_exp1;
		vanilla{k} 		= PM_error;
		vanilla1{k} 	= PM_error1;

	end


	plot_error( expThresh, expThresh1, vanilla, vanilla1 );

end


function plot_error( expThresh, expThresh1, vanilla, vanilla1 )

	CE 		= zeros(2,4);
	prec 	= zeros(2,4);
	rec 	= zeros(2,4);

	%% Supervoxel-basd
	%
	% novice + expert, major voting
	tp = sum(extractfield( cell2mat(expThresh), 'tp' ));
	fn = sum(extractfield( cell2mat(expThresh), 'fn' ));
	fp = sum(extractfield( cell2mat(expThresh), 'fp' ));
	CE(1,1) = (fn + fp)/(tp + fn + fp);
	prec(1,1) = tp/(tp + fp);
	rec(1,1) = tp/(tp + fn);
	% expert only, major voting
	tp = sum(extractfield( cell2mat(expThresh1), 'tp' ));
	fn = sum(extractfield( cell2mat(expThresh1), 'fn' ));
	fp = sum(extractfield( cell2mat(expThresh1), 'fp' ));
	CE(1,2) = (fn + fp)/(tp + fn + fp);
	prec(1,2) = tp/(tp + fp);
	rec(1,2) = tp/(tp + fn);
	% novice + expert, plug-in parameters
	tp = sum(extractfield( cell2mat(vanilla), 'tp' ));
	fn = sum(extractfield( cell2mat(vanilla), 'fn' ));
	fp = sum(extractfield( cell2mat(vanilla), 'fp' ));
	CE(1,3) = (fn + fp)/(tp + fn + fp);
	prec(1,3) = tp/(tp + fp);
	rec(1,3) = tp/(tp + fn);
	% expert only, plug-in parameters
	tp = sum(extractfield( cell2mat(vanilla1), 'tp' ));
	fn = sum(extractfield( cell2mat(vanilla1), 'fn' ));
	fp = sum(extractfield( cell2mat(vanilla1), 'fp' ));
	CE(1,4) = (fn + fp)/(tp + fn + fp);
	prec(1,4) = tp/(tp + fp);
	rec(1,4) = tp/(tp + fn);


	%% Voxel-basd
	%
	% novice + expert, major voting
	tpv = sum(extractfield( cell2mat(expThresh), 'tpv' ));
	fnv = sum(extractfield( cell2mat(expThresh), 'fnv' ));
	fpv = sum(extractfield( cell2mat(expThresh), 'fpv' ));
	CE(2,1) = (fnv + fpv)/(tpv + fnv + fpv);
	prec(2,1) = tpv/(tpv + fpv);
	rec(2,1) = tpv/(tpv + fnv);
	% expert only, major voting
	tpv = sum(extractfield( cell2mat(expThresh1), 'tpv' ));
	fnv = sum(extractfield( cell2mat(expThresh1), 'fnv' ));
	fpv = sum(extractfield( cell2mat(expThresh1), 'fpv' ));
	CE(2,2) = (fnv + fpv)/(tpv + fnv + fpv);
	prec(2,2) = tpv/(tpv + fpv);
	rec(2,2) = tpv/(tpv + fnv);
	% novice + expert, plug-in parameters
	tpv = sum(extractfield( cell2mat(vanilla), 'tpv' ));
	fnv = sum(extractfield( cell2mat(vanilla), 'fnv' ));
	fpv = sum(extractfield( cell2mat(vanilla), 'fpv' ));
	CE(2,3) = (fnv + fpv)/(tpv + fnv + fpv);
	prec(2,3) = tpv/(tpv + fpv);
	rec(2,3) = tpv/(tpv + fnv);
	% expert only, plug-in parameters
	tpv = sum(extractfield( cell2mat(vanilla1), 'tpv' ));
	fnv = sum(extractfield( cell2mat(vanilla1), 'fnv' ));
	fpv = sum(extractfield( cell2mat(vanilla1), 'fpv' ));
	CE(2,4) = (fnv + fpv)/(tpv + fnv + fpv);
	prec(2,4) = tpv/(tpv + fpv);
	rec(2,4) = tpv/(tpv + fnv);

	legendStr = {'novice + expert, major voting'; ...
				 'expert only, major voting'; ...
				 'novice + expert, plug-in parameters'; ...				 
				 'expert only, plug-in parameters'; ...				 
				};
	idx = [2 1 3 4];

	%% Plot
	%
	figure;

	% CE
	subplot(3,1,1);
	bar(CE(:,idx));
	grid on;

	legend(legendStr(idx),'Location','NorthEast');
	set(gca,'XTickLabel',{'Supervoxel-based','Voxel-based'});
	ylabel('Classification error');

	% precision
	subplot(3,1,2);
	bar(1-prec(:,idx));
	grid on;

	legend(legendStr(idx),'Location','NorthEast');
	set(gca,'XTickLabel',{'Supervoxel-based','Voxel-based'});
	ylabel('1 - Precision');

	% recall
	subplot(3,1,3);
	bar(1-rec(:,idx));
	grid on;

	legend(legendStr(idx),'Location','NorthEast');
	set(gca,'XTickLabel',{'Supervoxel-based','Voxel-based'});
	ylabel('1 - Recall');

end