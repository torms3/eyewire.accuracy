function plot_triples_m_slice( triples, m, celltype )

%% Argument validation
%
if( ~exist('celltype','var') )
	celltype = 'none';
end


figure();
colormap hot;

% threshold
th = m*get_celltype_threshold( m, celltype );
[best] = best_threshold( triples, m );

% sigma = 0 -> i = 1
% sigma = 1 -> i = 2
for i = 1:2

	% distribution
	% subplot(2,2,2*i-1);
	subplot(2,1,i);
	hold on;
	
		% slice data (fixed m)
		data = triples(m,1:m+1,i);

		% beta fitting
		% [ML,simple] = fit_beta_for_fixed_m(data, m);
		
		% plot
		xlim([-0.8 m+0.8]);
		xlabel('n');
		h = bar( 0:m, data, 1 );
		colorbar;

		% bar coloring
		ch = get( h, 'Children' );
		fvd = get( ch, 'Faces' );
		fvcd = get( ch, 'FaceVertexCData' );
		[zs,izs] = sort( data );
		for j = 1:numel(data)
			row = izs(j);
			fvcd(fvd(row,:)) = zs(j);
		end
		set( ch, 'FaceVertexCData', fvcd );

		% draw best decision line
		disp_th = best - 0.5;
		h1 = line([disp_th disp_th],ylim,'LineStyle','--','Color','b','LineWidth',2);

		% draw decision line		
		disp_th = floor(th) + 0.5;
		h2 = line([disp_th disp_th],ylim,'Color','r','LineWidth',2);

		legend([h1 h2],'best decision line','current decision lien','Location','best');
		title(sprintf('m = %d, sigma = %d',m,i-1));

	hold off;

	% beta fit
	% subplot(2,2,2*i);
	% hold on;
		
	% 	x=0:0.005:1;
	% 	y=betapdf(x,ones(1,numel(x))*ML(1),ones(1,numel(x))*ML(2));		
	% 	h1=plot(x,y,'-r');
	% 	%y=betacdf(x,ones(1,numel(x))*ML(1),ones(1,numel(x))*ML(2));
	% 	%plot(x,y,'-b');
	% 	fprintf('ML: alpha=%f, beta=%f\n',ML(1),ML(2));

	% 	y=betapdf(x,ones(1,numel(x))*simple(1),ones(1,numel(x))*simple(2));
	% 	h2=plot(x,y,'-k');
	% 	%y=betacdf(x,ones(1,numel(x))*simple(1),ones(1,numel(x))*simple(2));
	% 	%plot(x,y,'-b');
	% 	fprintf('Momenta: alpha=%f, beta=%f\n',simple(1),simple(2));
		
	% 	%str = sprintf( 'alpha=%f, beta=%f', a, b );
	% 	%text(sum(xlim)/2.,sum(ylim)*0.85,str,'FontSize',30,'FontWeight','bold');
	% 	grid on;

	% hold off;

end

[precision,recall] = cacluate_precision_recall( triples, m, th );
fprintf( 'precision=%f\n', precision );
fprintf( 'recall=%f\n', recall );

% % print recall
% subplot(2,2,2);
% prec_str = sprintf( 'Precision = %f', precision );
% text(sum(xlim)/2.,sum(ylim)*0.85,prec_str,'FontSize',30,'FontWeight','bold');

% % print precision
% subplot(2,2,4);
% recall_str = sprintf( 'Recall = %f', recall );
% text(sum(xlim)/2.,sum(ylim)*0.85,recall_str,'FontSize',30,'FontWeight','bold');

end


function [precision,recall] = cacluate_precision_recall( triples, m, th )

	% floor( threshold )
	f_th = floor( th );

	% data for true postive & false negative
	data = triples(m,1:m+1,2);
	% assert( f_th+2 <= length(data) );

	% true positive & false negative
	tp = sum( data(f_th+2:end) );
	fn = sum( data(1:f_th+1) );

	% data for false positive
	data = triples(m,1:m+1,1);
	% assert( f_th+2 <= length(data) );

	% false positive & true negative
	fp = sum( data(f_th+2:end) );
	tn = sum( data(1:f_th+1) );

	% precision & recall
	precision   = double(tp)/double(tp+fp);
	recall      = double(tp)/double(tp+fn);

end


function [best] = best_threshold( triples, m )

	fs = zeros(m,1);

	thresh = 1:m;
	for i = 1:numel(thresh)

		th = thresh(i) - 0.5;
		[prec,rec] = cacluate_precision_recall( triples, m, th );
		fs(i) = (2*prec*rec)/(prec+rec);

	end

	[~,idx] = sort(fs,'descend');
	best = idx(1);

end