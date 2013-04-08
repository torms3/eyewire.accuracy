function plot_triples_prec_recall_curve( triples, min_m, max_m )

num_m = max_m - min_m + 1;

figure();
cmap = colormap( jet(num_m) );

% current threshold and theoretical frontier
threshold = zeros( num_m, 2 );
frontier = zeros( num_m, 2 );

% guide line y = x
x = 0:.1:1;
y = x;
plot(x,y,'-k');

% for gathering real & optimal threshold values for each m
real_th = zeros( num_m, 1 );
optimal_th = zeros( num_m, 1 );

hold on;
for i = min_m:max_m

	m = i;
	m_idx = m - min_m + 1;

	prc = zeros( m, 1 );
	rec = zeros( m, 1 );
	for j = 0:m-1
		
        th = j;
		[prc(j+1),rec(j+1)] = cacluate_precision_recall( triples, m, th );

    end
        
    % plot precision & recall curve
    plot(rec,prc,'Color',cmap(m_idx,:),'LineWidth',1.5);

	% threshold
	th_real = m*(exp(-0.16*m)+0.2);
	th = floor(th_real);
	threshold(m_idx,1) = rec(th+1);
	threshold(m_idx,2) = prc(th+1);
	real_th(m_idx) = th_real;

	% theoretical frontier
	f_measure = 2*((prc.*rec)./(prc+rec));
	[~,idx] = sort( f_measure, 'descend' );
	frontier(m_idx,1) = rec(idx(1));
	frontier(m_idx,2) = prc(idx(1));
	optimal_th(m_idx) = idx(1)-1;

end

% plot current threshold and theoretical frontier
h1 = plot(threshold(:,1),threshold(:,2),'ok','MarkerFaceColor','k');
h2 = plot(frontier(:,1),frontier(:,2),'xr','MarkerSize',7,'LineWidth',2);

legend([h1,h2],'Current Threshold','Frontier (F-measure)','Location','Best');
xlabel('Recall');
ylabel('Precision');
title('Precision vs. Recall Curve for each m, with threshold for n being varied');
grid on;
caxis([min_m max_m+1]);
h_cb = colorbar;
set(h_cb,'YLim',[min_m max_m+1]);
xlabel( h_cb, 'm' );

hold off;

% real & optimal threshold (n vs. m)
figure();
hold on;
h1=plot(min_m:max_m, real_th,'-ok');
h2=plot(min_m:max_m, floor(real_th),'ok','MarkerFaceColor','k');
h3=plot(min_m:max_m, optimal_th,'or','MarkerSize',7,'LineWidth',2);
xlabel('m');
ylabel('threshold (n)');
title('Threshold for n in each segment to be regarded as truth');
legend([h1,h2,h3],'real-valued threshold','discretized threshold','descretized frontier (F-measure)','Location','Best');
grid on;
hold off;

% real & optimal threshold (n/m vs. m)
figure();
hold on;
x=min_m:max_m;
y1=exp(-0.16*x)+0.2;
h1=plot(x,y1,'-ok');
y2=floor(x.*y1)./x;
h2=plot(x, y2,'ok','MarkerFaceColor','k');
y3=optimal_th'./x;
h3=plot(x, y3,'or','MarkerSize',7,'LineWidth',2);
xlabel('m');
ylabel('threshold probability (n/m)');
ylim([0 1.0]);
% title('Threshold for n in each segment to be regarded as truth');
legend([h1,h2,h3],'real-valued threshold probability', ...
				'discretized threshold probability', ...
				'descretized frontier probability (F-measure)', ...
				'Location','Best');
grid on;
hold off;

end


function [precision,recall] = cacluate_precision_recall( triples, m, th )

% floor( threshold )
f_th = floor( th );

% data for true postive & false negative
data = triples(m,1:m+1,2);
%assert( f_th+2 <= length(data) );

% true positive & false negative
tp = sum( data(f_th+2:end) );
fn = sum( data(1:f_th+1) );

% data for false positive
data = triples(m,1:m+1,1);
%assert( f_th+2 <= length(data) );

% false positive & true negative
fp = sum( data(f_th+2:end) );
tn = sum( data(1:f_th+1) );

% precision & recall
% Precision & recall
precision   = double(tp)/double(tp+fp);
recall      = double(tp)/double(tp+fn);

end