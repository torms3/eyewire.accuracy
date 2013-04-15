function plot_userwise_learning_curve( uStat, window_size, step_size )

% initialization
n_step = ceil((uStat.nv - window_size)/step_size) + 1;
prec = zeros(1,n_step);
rec = zeros(1,n_step);
fs = zeros(1,n_step);
hot = zeros(1,n_step);

% moving accuracy
head_idx = 1;
for i = 1:n_step

	tail_idx = min(head_idx + window_size - 1, uStat.nv);
	idx = head_idx:tail_idx;
	
	[prec(i),rec(i),fs(i),hot(i)] = compute_windowed_accuracy( uStat, idx );

	head_idx = head_idx + step_size;

end

x = 1:n_step;
subplot(3,1,1);
plot(x,prec,x,rec,x,fs);
legend('prec','rec','fs','Location','Best');
grid on;
grid minor;
subplot(3,1,2);
plot(x,hot);
grid on;
grid minor;
subplot(3,1,3);
plot(uStat.cell);
grid on;
grid minor;

end


function [prec,rec,fs,hot] = compute_windowed_accuracy( uStat, idx )

	hot = sum(uStat.hot(idx));

	tpv = sum(uStat.tpv(idx));
	fnv = sum(uStat.fnv(idx));
	fpv = sum(uStat.fpv(idx));

	% precision
	prec = tpv/(tpv + fpv);
	if( isnan(prec) )
		prec = 0;
	end

	% recall
	rec = tpv/(tpv + fnv);
	if( isnan(rec) )
		rec = 0;
	end

	% f-measure
	fs = 2*(prec*rec)/(prec + rec);
	if( isnan(fs) )
		fs = 0;
	end

end