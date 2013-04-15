function plot_learning_curve( STAT, window_size, step_size )

%% User-wise processing
%
% vals 	= STAT.keys;
% for i = 1:STAT.Count

% 	uStat = vals{i};
% 	plot_userwise_learning_curve( uStat, window_size, step_size );

% end
hold on;
% uStat = STAT(2817);
% uStat = U(23095);
% uStat = U(9641);
plot_userwise_learning_curve( uStat, window_size, step_size );
hold off;

% figure();
% plot(uStat.hot);

end