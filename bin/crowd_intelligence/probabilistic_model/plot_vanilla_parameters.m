function plot_vanilla_parameters( savePath )

fileName = 'ERR__cell_*';
fileList = dir([savePath '/' fileName]);
nFile = numel(fileList);

cellIDs = zeros(nFile,1);
CE = zeros(nFile,4);
prec = zeros(nFile,4);
rec = zeros(nFile,4);

for i = 1:nFile

	load([savePath '/' fileList(i).name]);

	C = textscan(fileList(i).name,'ERR__cell_%d.mat');
	cellIDs(i) = cell2mat(C);
	
	CE(i,1) = ERR.exp.CE;
	CE(i,2) = ERR_wo_v0.exp.CE;
	CE(i,3) = ERR.v_error.CE;
	CE(i,4) = ERR_wo_v0.v_error.CE;

	prec(i,1) = ERR.exp.v_prec;
	prec(i,2) = ERR_wo_v0.exp.v_prec;
	prec(i,3) = ERR.v_error.v_prec;
	prec(i,4) = ERR_wo_v0.v_error.v_prec;

	rec(i,1) = ERR.exp.v_rec;
	rec(i,2) = ERR_wo_v0.exp.v_rec;
	rec(i,3) = ERR.v_error.v_rec;
	rec(i,4) = ERR_wo_v0.v_error.v_rec;

end

subplot(3,1,1);
bar(CE);
labels = strtrim(cellstr(num2str(cellIDs))');
set(gca,'XTickLabel',labels);
ylabel('Classification error');
grid on;

subplot(3,1,2);
bar(prec);
ylim([0.8 1.0]);
labels = strtrim(cellstr(num2str(cellIDs))');
set(gca,'XTickLabel',labels);
ylabel('Precision');
grid on;
grid minor;

subplot(3,1,3);
bar(rec);
ylim([0.90 1.0]);
labels = strtrim(cellstr(num2str(cellIDs))');
set(gca,'XTickLabel',labels);
ylabel('Recall');
grid on;
grid minor;

end