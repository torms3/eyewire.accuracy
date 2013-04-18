function [best_fs,best_th] = AI_batch( save_path, DB_MAPs )

best_fs = 0.0;
best_th = 0.0;

% threshold = fliplr(0.04:0.05:0.94);
% threshold = fliplr(0.981:0.001:0.989);
% threshold = fliplr(0.951:0.001:0.959);
% threshold = fliplr(0.941:0.001:0.949);
% threshold = fliplr(0.961:0.001:0.969);
threshold = fliplr(0.971:0.001:0.979);
for th = threshold
	
	[AI_MAP] = AI_calculate_accuracy( DB_MAPs, th );

	file_name = sprintf('AI_MAP__thresh_%f.mat',th);
	save([save_path file_name],'AI_MAP');

	tpv = sum(extractfield( cell2mat(AI_MAP.values), 'tpv' ));
	fnv = sum(extractfield( cell2mat(AI_MAP.values), 'fnv' ));
	fpv = sum(extractfield( cell2mat(AI_MAP.values), 'fpv' ));

	prec = tpv/(tpv+fpv);
	rec = tpv/(tpv+fnv);
	fs = 2*(prec*rec)/(prec+rec);

	if( best_fs < fs )
		best_fs = fs;
		best_th = th;
		fprintf('Best f-score = %f\n',best_fs);
		fprintf('Best threshold = %f\n',best_th);
	end

end

end