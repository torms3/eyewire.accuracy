function visualize_SAC_daily_validations_per_user( daily_stat )

nuv = daily_stat.nuv;
mode_uID = daily_stat.mode_uID;

max_v = max(cellfun(@sum,nuv));
max_n = max(cellfun(@numel,nuv));
v_map = ones(max_v,numel(nuv))*max_n;

for i = 1:numel(nuv)

	uv = nuv{i};
	head_idx = 1;
	val = 0;
	for j = 1:numel(uv)

		tail_idx = head_idx + uv(j) - 1;
		v_map(head_idx:tail_idx,i) = val;
		val = val + 1;
		head_idx = tail_idx + 1;

	end

end

figure();
image(v_map);
% set(gcf,'Color','k');
% set(gca,'XColor','w');
% set(gca,'YColor','w');
% grid on;
colormap([lines(max_n-1);[0 0 0]]);
set(gca,'YDir','normal');
set(gca,'XTick',[1 8 15 22]);
set(gca,'XTickLabel',['2013-03-15';'2013-03-22';'2013-03-29';'2013-04-05']);
xlabel('Date');
ylabel('Number of daily validations');
title('Number of SAC daily validations per user');

end