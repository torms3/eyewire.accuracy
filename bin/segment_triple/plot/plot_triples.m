function plot_triples( triples )

figure();

for i = 1:2

	% crop image
	img = triples(:,:,i);
	[row,col] = find(img);
	% dim = max(max(row),max(col));
	dim = 30;
	img = img(1:dim,1:dim);

	% draw image
	subplot(2,2,i*2-1);

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

	hold off;

end

%% probability
result = double(triples(:,:,2))./double(triples(:,:,1) + triples(:,:,2));
result(isnan(result)) = 0;

% crop image
img = result;
[row,col] = find(img);
% dim = max(max(row),max(col));
dim = 30;
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
f_m = floor(m.*(exp(-0.16*m)+0.2));
p = plot(m,f_m,'b');
set(p,'LineWidth',2);

hold off;

end