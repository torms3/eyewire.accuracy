function collective_accuracy( M, nCube, window_size, step_size )

nv = sum(M(:,:,1) >= 0,2);
idx = nv > nCube;
nUser = nnz(idx);
subM = zeros(nUser,nCube,3);

fprintf('%d users submitted more than %d validations.\n',nUser,nCube);

subM = M(idx,1:nCube,:);
tpv = sum(subM(:,:,1),1);
fnv = sum(subM(:,:,2),1);
fpv = sum(subM(:,:,3),1);

nStep = ceil((nCube - window_size)/step_size) + 1;
prec = zeros(1,nStep);
rec = zeros(1,nStep);
fs = zeros(1,nStep);

% moving accuracy
head_idx = 1;
for i = 1:nStep

	tail_idx = min(head_idx + window_size - 1, nCube);
	idx = head_idx:tail_idx;
	
	ltpv = sum(tpv(idx));
	lfnv = sum(fnv(idx));
	lfpv = sum(fpv(idx));

	prec(i) = ltpv/(ltpv + lfpv);
	rec(i) = ltpv/(ltpv + lfnv);
	fs(i) = 2*(prec(i)*rec(i))/(prec(i) + rec(i));

	head_idx = head_idx + step_size;

end

x = 1:nStep;
x = x + floor(window_size/2);
plot(x,prec,x,rec,x,fs);
legend('precision','recall','f-score','Location','Best');
grid on;
xlabel('center of moving window');
ylabel('collective accuracy');
title_str = sprintf('%d users, first %d validations, window size = %d, step size = %d',nUser,nCube,window_size,step_size);
title(title_str);

end