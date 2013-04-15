function compare_tutorial_and_EyeWire_performance( TUT_STAT, STAT, nCube )

[tut_uIDs,tut_perf] = TUT_compute_tutorial_performance( TUT_STAT );
[uIDs,perf] = compute_windowed_EyeWire_accuracy( STAT, 1:nCube );

[~,IA,IB] = intersect(tut_uIDs,uIDs);
tut_perf = cell2mat(tut_perf);
perf = cell2mat(perf);


%% Precision
%
tut_prec = extractfield( tut_perf(IA), 'prec' );
prec = extractfield( perf(IB), 'prec' );
assert( numel(tut_prec) == numel(prec) );

valid_idx = ~(isnan(tut_prec) | isnan(prec));
tut_prec = tut_prec(valid_idx);
prec = prec(valid_idx);

subplot(2,2,1);
scatter(tut_prec,prec);
xlabel('Tutorial precision');
ylabel('EyeWire precision');
title('Tutorial precision vs. EyeWire precision');

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
scatter(tut_rec,rec);
xlabel('Tutorial recall');
ylabel('EyeWire recall');
title('Tutorial recall vs. EyeWire recall');

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
scatter(tut_fs,fs);
xlabel('Tutorial f-score');
ylabel('EyeWire f-score');
title('Tutorial f-score vs. EyeWire f-score');

corrcoef(tut_fs,fs)

end