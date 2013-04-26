function [AI_accuracy] = AI_extract_accuracy( filePath )

fileName = 'AI_MAP__thresh_*';
fileList = dir([filePath '/' fileName]);
nFile = numel(fileList);
AI_accuracy = cell(1,nFile);
for i = 1:nFile

	load([filePath '/' fileList(i).name]);	% load AI_MAP
	vals = AI_MAP.values;
	AI_accuracy{i}.threshold = vals{1}.threshold;

	tpv = sum(extractfield( cell2mat(vals), 'tpv' ));
	fnv = sum(extractfield( cell2mat(vals), 'fnv' ));
	fpv = sum(extractfield( cell2mat(vals), 'fpv' ));

	prec = tpv/(tpv + fpv);
	rec = tpv/(tpv + fnv);
	fs = 2*(prec*rec)/(prec + rec);
	CE = (fnv + fpv)/(tpv + fnv + fpv);

	AI_accuracy{i}.prec = prec;
	AI_accuracy{i}.rec = rec;
	AI_accuracy{i}.fs = fs;
	AI_accuracy{i}.CE = CE;

	AI_accuracy{i}.tpv = tpv;
	AI_accuracy{i}.fnv = fnv;
	AI_accuracy{i}.fpv = fpv;

end

end