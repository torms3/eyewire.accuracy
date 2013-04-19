function plot_triples( triples )

%% Option
%
probability = false;


%% Plot
%
figure();

for i = 1:2

	% crop image
	img = triples(:,:,i);
	[row,col] = find(img);
	% dim = max(max(row),max(col));
	dim = 33;
	img = img(1:dim,1:dim);

	% draw image
	if( probability)
		subplot(2,2,i*2-1);
	else
		subplot(1,2,i);	
	end

	set(gca,'Color','k')
	xlim([0.5 dim+0.5]);
	ylim([-0.5 dim-0.5]);

	hold on;

	imagesc([1 dim],[0 dim-1],img');
	colormap hot;
	colorbar;

	m = 1:dim;
	f_m = floor(m.*(exp(-0.16*m)+0.2));
	p = plot(m,f_m,'b');
	set(p,'LineWidth',2);

	pbaspect([1 1 1]);
	title_str = sprintf('sigma = %d',i - 1);
	title(title_str);

	hold off;

end

%% probability
%
if( probability )
	result = double(triples(:,:,2))./double(triples(:,:,1) + triples(:,:,2));
	result(isnan(result)) = 0;

	% crop image
	img = result;
	[row,col] = find(img);
	% dim = max(max(row),max(col));
	dim = 33;
	img = img(1:dim,1:dim);

	% draw image
	subplot(2,2,2);

	set(gca,'Color','k')
	xlim([0.5 dim+0.5]);
	ylim([-0.5 dim-0.5]);

	hold on;

	imagesc([1 dim],[0 dim-1],img');
	colormap hot;
	colorbar;

	m = 1:dim;
	% f_m = floor(m.*(exp(-0.16*m)+0.2));

	a = 0.75;
	b = 0.24;
	c = 0.22;
	f_m = floor(m.*min(0.99,a*exp(-b*m)+c));

	p = plot(m,f_m,'b');
	set(p,'LineWidth',2);

	hold off;
end

end