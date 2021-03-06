function learning_curve( M, nCube, wSize, step )

%% Options
%
plot_collective = false;
plot_average = false;
plot_individual = false;
plot_quartiles = true;
plot_shadedQualtiles = true;


%% Global variables
%
global g_nUser g_nCube g_step colHot;
g_nCube = nCube;
g_step = step;


nv = sum(M(:,:,1) > -1,2);
idx = nv > nCube;
nUser = nnz(idx);
g_nUser = nUser;

fprintf('%d users submitted more than %d validations.\n',nUser,nCube);

subM = M(idx,1:nCube,1:3);
% HOT = M(idx,1:nCube,4);
% sum(sum(HOT))*100/(nUser*nCube)
TPV = subM(:,:,1);
FNV = subM(:,:,2);
FPV = subM(:,:,3);

% TPV = TPV.*(~HOT);
% FNV = FNV.*(~HOT);
% FPV = FPV.*(~HOT);

nStep = ceil((nCube - wSize)/step) + 1;

% for collective accuracy
prec = zeros(1,nStep);
rec = zeros(1,nStep);
fs = zeros(1,nStep);

% for average accuracy
aPrec = zeros(1,nStep);
aRec = zeros(1,nStep);
aFs = zeros(1,nStep);
stdErr = zeros(3,nStep);	% for aPrec, aRec, and aFs

% individual learnig curve
uPrec = zeros(nUser,nStep);
uRec = zeros(nUser,nStep);
uFs = zeros(nUser,nStep);

% qualtiles
qPrec = zeros(3,nStep);
qRec = zeros(3,nStep);
qFs = zeros(3,nStep);

% hotspot analysis
% global uFnv uFpv uHotFnv uHotFpv;
% uFnv = zeros(nUser,nStep);
% uFpv = zeros(nUser,nStep);
% uHotFnv = zeros(nUser,nStep);
% uHotFpv = zeros(nUser,nStep);

% moving window
head_idx = 1;
for i = 1:nStep

	tail_idx = min(head_idx + wSize - 1, nCube);
	idx = head_idx:tail_idx;
	
	% window
	tpv = TPV(:,idx);
	fnv = FNV(:,idx);
	fpv = FPV(:,idx);

	% collective accuracy
	colTpv = sum(sum(tpv));
	colFnv = sum(sum(fnv));
	colFpv = sum(sum(fpv));

	prec(i) = colTpv/(colTpv + colFpv);
	rec(i) = colTpv/(colTpv + colFnv);
	fs(i) = 2*(prec(i)*rec(i))/(prec(i) + rec(i));	

	% for individual learning curve and average accuracy
	usrTpv = sum(tpv,2);	% tpv
	usrFnv = sum(fnv,2);	% fnv
	usrFpv = sum(fpv,2);	% fpv

	uFnv(:,i) = usrFnv;
	uFpv(:,i) = usrFpv;

	% hotIdx = HOT(:,idx);
	% usrHotTpv = sum(hotIdx.*tpv,2);
	% usrHotFnv = sum(hotIdx.*fnv,2);
	% usrHotFpv = sum(hotIdx.*fpv,2);

	% uHotFnv(:,i) = usrHotFnv;
	% uHotFpv(:,i) = usrHotFpv;

	
	% individual learning curve
	uPrec(:,i) = usrTpv./(usrTpv + usrFpv);
	uRec(:,i) = usrTpv./(usrTpv + usrFnv);
	uFs(:,i) = 2*(uPrec(:,i).*uRec(:,i))./(uPrec(:,i) + uRec(:,i));
		
	% average accuracy
	aPrec(i) = mean(uPrec(:,i));	
	aRec(i) = mean(uRec(:,i));
	% aFs(i) = 2*(aPrec(i)*aRec(i))/(aPrec(i) + aRec(i));
	aFs(i) = mean(uFs(:,i));

	% qualtiles
	qPrec(:,i) = quantile(uPrec(:,i),[0.25,0.5,0.75]');
	qRec(:,i) = quantile(uRec(:,i),[0.25,0.5,0.75]');
	qFs(:,i) = quantile(uFs(:,i),[0.25,0.5,0.75]');
	
	stdErr(1,i) = std(uPrec(:,i));
	stdErr(2,i) = std(uRec(:,i));
	stdErr(3,i) = std(uFs(:,i));

	% slide the moving window
	head_idx = head_idx + step;

end


%% Plot
%
x = 1:step:(head_idx-step);
x = x + floor(wSize/2);	% center of the moving window

title_str = sprintf('%d users, first %d validations, window size = %d, step size = %d',nUser,nCube,wSize,step);

% collective accuracy
if( plot_collective )
	plot_collective_accuracy( x, prec, rec, fs );
	title(title_str);
end

% average accuracy
if( plot_average )
	plot_average_accuracy( x, aPrec, aRec, aFs, stdErr );
	title(title_str);
end

% indificual learning curve
if( plot_individual )
	plot_individual_learning_curve( x, uPrec, uRec, uFs );
end

% quartiles
if( plot_quartiles )
	plot_quartiles_accuracy( x, qPrec, qRec, qFs );
	title(title_str);
end

% shaded quartiles
if( plot_shadedQualtiles )
	plot_shaded_quartiles_accuracy( x, qPrec, qRec, qFs );
	title(title_str);
end

end


function plot_collective_accuracy( x, prec, rec, fs );
	
	figure;
	plot(x,prec,x,rec,x,fs);
	legend('precision','recall','f-score','Location','Best');
	grid on;
	xlabel('center of moving window');
	ylabel('collective accuracy');	

end


function plot_average_accuracy( x, aPrec, aRec, aFs, stdErr )
	
	global g_step;
	
	figure;
	% plot(x,aPrec,x,aRec,x,aFs);
	% legend('precision','recall','f-score','Location','Best');
	% plot(x,aPrec,x,aRec);
	% legend('precision','recall','Location','Best');
	hold on;
	skew = 0.3*g_step;
	h1 = plot(x+skew,aRec,'-r','LineWidth',2);
	errorbar(x+skew,aRec,stdErr(2,:),'-.r','MarkerFaceColor','r');
	h2 = plot(x,aPrec,'-b','LineWidth',2);
	errorbar(x,aPrec,stdErr(1,:),'-.b','MarkerFaceColor','b');
	hold off;
	legend([h1 h2],'recall','precision','Location','Best');
	% errorbar(x,aFs,stdErr(1,:),'-ob');
	grid on;
	xlabel('center of moving window');
	ylabel('average accuracy');

end


function plot_individual_learning_curve( x, uPrec, uRec, uFs )

	nUser = size(uPrec,1);
	X = ones(nUser,1)*x;
	% X = reshape(X,1,[]);
	figure;

	% precision
	subplot(1,2,1);
	plot(x,uPrec,'b.');
	% h = scatter(X,reshape(uPrec,1,[]),'ob','filled');
	xlabel('center of moving window');
	ylabel('individual precision');
	grid on;
	
	% recall
	subplot(1,2,2);
	plot(x,uRec,'r.');
	% h = scatter(X,reshape(uRec,1,[]),'or','filled');
	xlabel('center of moving window');
	ylabel('individual recall');
	grid on;
	
end


function plot_quartiles_accuracy( x, qPrec, qRec, qFs )

	figure;
	hold on;
	h = zeros(1,6);

	xlim([0 500]);
	
	% Q3 (75%)
	h(1) = plot(x,qRec(3,:),'-r','LineWidth',0.5);
	h(2) = plot(x,qPrec(3,:),'-b','LineWidth',0.5);
	
	% Q2 (50%)
	h(3) = plot(x,qRec(2,:),'-r','LineWidth',2);
	h(4) = plot(x,qPrec(2,:),'-b','LineWidth',2);	

	% Q1 (25%)
	h(5) = plot(x,qRec(1,:),'-r','LineWidth',5);
	h(6) = plot(x,qPrec(1,:),'-b','LineWidth',5);

	hold off;
	legend(h,'Q3 recall','Q3 precision','Q2 recall','Q2 precision','Q1 recall','Q1 precision','Location','Best');
	xlabel('center of moving window');
	ylabel('quartiles of accuracy');
	grid on;

end


function plot_shaded_quartiles_accuracy( x, qPrec, qRec, qFs )

	figure;
	hold on;
	% h = zeros(1,6);
	% xlim([0 500]);	
	
	% precision
	upperError = qPrec(1,:) - qPrec(2,:);
	lowerError = qPrec(2,:) - qPrec(3,:);
	errorBar = [upperError;lowerError];
	w = 1;
	h1=plot(x,qPrec(2,:),'-b','LineWidth',w);
	shadedErrorBar(x,qPrec(2,:),errorBar,{'-b','LineWidth',w},1);

	% recall
	upperError = qRec(1,:) - qRec(2,:);
	lowerError = qRec(2,:) - qRec(3,:);
	errorBar = [upperError;lowerError];
	w = 1;
	h2=plot(x,qRec(2,:),'-r','LineWidth',w);
	shadedErrorBar(x,qRec(2,:),errorBar,{'-r','LineWidth',1},1);

	hold off;
	legend([h1 h2],'precision','recall','Location','Best');
	xlabel('center of moving window');
	ylabel('quartiles of accuracy');
	% grid on;

end