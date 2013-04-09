function plot_SAC_threshold()

m = 1:50;
th_real = min(0.99,exp(-0.16*m)+0.2);

% a = 0.85;
% b = 0.22;
% c = 0.2;

% d = 0.04;
% e = 17;
% f = 40.0;

% a = 0.7;
% b = 0.22;
% c = 0.2;

% d = 0.05;
% e = 14;
% f = 80.0;

% a = 1.0;
% b = 0.16;
% c = 0.2;

% d = -0.22;
% e = 5.0;
% f = 12.0;

a = 0.92;
b = 0.155;
c = 0.2;

d = -0.22;
e = 5.85;
f = 12.0;

th_exp = a*exp(-b*m)+c;
th_bump = d*exp(-(m-e).^2./f);
modified = min(0.99,th_exp+th_bump);

% real threshold (n vs. m)
figure();
subplot(1,2,1);
hold on;
h1=plot(m,m.*th_real,'-ok');
h2=plot(m,ceil(m.*th_real),'ok','MarkerFaceColor','k','MarkerSize',8);
h3=plot(m,m.*modified,'-or');
h4=plot(m,ceil(m.*modified),'or','MarkerFaceColor','r');
xlabel('m');
ylabel('threshold (n)');
title('Threshold for n in each segment to be regarded as truth');
legend([h1,h2,h3,h4],'real-valued threshold', ...
					 'discretized threshold', ...
					 'real-valued modified threshold', ...
					 'discretized modified threshold', ...
					 'Location','NorthWest');
grid on;
hold off;

% real threshold (n vs. m)
subplot(1,2,2);
hold on;
h1=plot(m,th_real,'-ok');
h2=plot(m,modified,'-or');
xlabel('m');
ylabel('threshold (probability)');
title('Threshold for n in each segment to be regarded as truth');
legend([h1,h2],'real-valued threshold','modified threshold','Location','NorthEast');
grid on;
hold off;


end