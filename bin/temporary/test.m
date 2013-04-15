
[~,IA,IB] = intersect(uIDs1,uIDs2);

tut_perf = cell2mat(perf1);
perf = cell2mat(perf2);


%% Precision
%
tut_prec = extractfield( tut_perf(IA), 'prec' );
prec = extractfield( perf(IB), 'prec' );
assert( numel(tut_prec) == numel(prec) );

valid_idx = ~(isnan(tut_prec) | isnan(prec));
tut_prec = tut_prec(valid_idx);
prec = prec(valid_idx);

subplot(2,2,1);
xlim([0 1.0]);
ylim([0 1.0]);
scatter(tut_prec,prec);
xlabel('Tutorial precision');
ylabel('EyeWire precision');
title('Tutorial precision vs. EyeWire precision');
daspect([1 1 1]);
grid on;

corrcoef(tut_prec,prec)


%% Recall
%
tut_rec = extractfield( tut_perf(IA), 'rec' );
rec = extractfield( perf(IB), 'rec' );
assert( numel(tut_rec) == numel(rec) );

valid_idx = ~(isnan(tut_rec) | isnan(rec));
tut_rec = tut_rec(valid_idx);
rec = rec(valid_idx);

subplot(2,2,2);
xlim([0 1]);
ylim([0 1]);
scatter(tut_rec,rec);
xlabel('Tutorial recall');
ylabel('EyeWire recall');
title('Tutorial recall vs. EyeWire recall');
daspect([1 1 1]);
grid on;

corrcoef(tut_rec,rec)


%% F-score
%
tut_fs = extractfield( tut_perf(IA), 'fs' );
fs = extractfield( perf(IB), 'fs' );
assert( numel(tut_fs) == numel(fs) );

valid_idx = ~(isnan(tut_fs) | isnan(fs));
tut_fs = tut_fs(valid_idx);
fs = fs(valid_idx);

subplot(2,2,3);
xlim([0 1]);
ylim([0 1]);
scatter(tut_fs,fs);
xlabel('Tutorial f-score');
ylabel('EyeWire f-score');
title('Tutorial f-score vs. EyeWire f-score');
daspect([1 1 1]);
grid on;

corrcoef(tut_fs,fs)

% triples = zeros(max(m),max(m)+1,2);
% for i = 1:numel(m)

% 	triples(m(i),n(i),data.sigma(i)+1) = triples(m(i),n(i),data.sigma(i)+1) + 1;

% end

%%

% T = DB_MAPs.T;
% V = DB_MAPs.V;

% seg_num = 0;

% for i = 1:numel(weird_tIDs)

% 	tID = weird_tIDs(i);
% 	tInfo = T(tID);
% 	vIDs = tInfo.vIDs;
% 	for j = 1:numel(vIDs)

% 		vID = vIDs(j);
% 		vInfo = V(vID);
% 		seg_num = seg_num + numel(vInfo.segs);

% 	end

% end

%%

% T = DB_MAPs.T;
% V = DB_MAPs.V;

% nv = zeros(1,T.Count);
% nv_w1 = zeros(1,T.Count);
% w  = zeros(1,T.Count);
% c  = zeros(1,T.Count);

% keys 	= T.keys;
% vals 	= T.values;
% for i = 1:T.Count

% 	tInfo = vals{i};
% 	vIDs = tInfo.vIDs;
	
% 	nv(i) = numel(vIDs);
% 	w(i)  = tInfo.weight;
% 	c(i)  = tInfo.datenum;

% 	vInfos = values( V, num2cell(vIDs) );
% 	vw = extractfield( cell2mat(vInfos), 'weight' );
% 	vw = min(vw,1);
% 	nv_w1(i) = sum(vw);

% end

% unames = extractfield( cell2mat(STAT.values), 'username' );

% top14 = {'a5hm0r','blackblues','crazyman4865','ketta','bigbiff','lobusparietalis','susi','acida_2','robz90','furball13','nkem','jinbean','reb1618','marika'};

% uIDs = cell2mat(STAT.keys);
% top14_idx = ismember(unames,top14);
% remove( STAT, num2cell(uIDs(~top14_idx)) );