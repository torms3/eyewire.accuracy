function [bestFs,bestThresh] = AI_batch_search_for_best_threshold( filePath )

fileName='AI_MAP__thresh_*';
fileList=dir([filePath fileName]);
nFile=numel(fileList);
bestFs=0.0;
bestThresh=0.0;
prec=zeros(1,nFile);
rec=zeros(1,nFile);
fs=zeros(1,nFile);
CE=zeros(1,nFile);
thresh=zeros(1,nFile);
for i=1:nFile

	load([filePath fileList(i).name]);	% load AI_MAP
	vals=AI_MAP.values;
	thresh(i)=vals{1}.threshold;

	tpv=sum(extractfield(cell2mat(vals),'tpv'));
	fnv=sum(extractfield(cell2mat(vals),'fnv'));
	fpv=sum(extractfield(cell2mat(vals),'fpv'));

	prec(i)=tpv/(tpv+fpv);
	rec(i)=tpv/(tpv+fnv);
	fs(i)=2*(prec(i)*rec(i))/(prec(i)+rec(i));
	CE(i)=(fnv+fpv)/(tpv+fnv+fpv);

	if(bestFs<fs(i))
		bestFs=fs(i);
		bestThresh=thresh(i);

		% disp(fs);
		% disp(thresh(i));
		% fprintf('tpv=%d\n',tpv);
		% fprintf('fnv=%d\n',fnv);
		% fprintf('fpv=%d\n',fpv);
		% fprintf('prec=%d\n',prec(i));
		% fprintf('rec=%d\n',rec(i));
		% fprintf('fs=%d\n',fs(i));
		% fprintf('CE=%d\n',CE);
		% fprintf('\n\n');
	end

end

plot(thresh,prec,'-o',thresh,rec,'-o',thresh,fs,'-o',thresh,CE,'-o');
legend('prec','rec','fs','CE','Location','Best');
grid on;


end