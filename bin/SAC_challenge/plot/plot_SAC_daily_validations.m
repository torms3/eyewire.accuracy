function plot_SAC_daily_validations( daily_stat )

%% Options
%
weekend_bg = 'bar';
% weekend_bg = 'line';


%% Extract information from stat
%
% nv = [];
nv_w1 = [];
nv_w0 = [];
nt = [];
% new_nv = [];
new_nv_w1 = [];
new_nv_w0 = [];
new_nt = [];
for i = 1:numel(daily_stat)

	nv_w1 = [nv_w1;daily_stat{i}.nv_w1];
	nv_w0 = [nv_w0;daily_stat{i}.nv_w0];
	% nv = [nv;daily_stat{i}.nv_w1;daily_stat{i}.nv_w0];

	nt = [nt;daily_stat{i}.nt];
	new_nt = [new_nt;daily_stat{i}.new_nt];

	new_nv_w1 = [new_nv_w1;daily_stat{i}.new_nv_w1];
	new_nv_w0 = [new_nv_w0;daily_stat{i}.new_nv_w0];
	% new_nv = [new_nv;daily_stat{i}.new_nv_w1;daily_stat{i}.new_nv_w0];

end
nv = nv_w1 + nv_w0;
new_nv = new_nv_w1 + new_nv_w0;


% SAC challenge date
start_date = datenum('2013-03-15 00:00:00','yyyy-mm-dd HH:MM:SS');
end_date = datenum(date);
n_days = end_date - start_date + 1;
datenums = start_date:end_date;
day_numbers = weekday(datenums);
weekend_idx = (day_numbers == 7) | (day_numbers == 1);
monday_idx = (day_numbers == 2);
weekend_str = datestr(datenums(weekend_idx),'mm-dd');
monday_str = datestr(datenums(monday_idx),'yyyy-mm-dd');

% users
nu = zeros(1,n_days);
uIDs = cell(1,n_days);
for i = 1:n_days
	
	for j = 1:numel(daily_stat)
		uIDs{i} = union(uIDs{i},daily_stat{j}.uIDs{i});
	end
	nu(i) = numel(uIDs{i});

end


%% Plot
%
figure();


%% Daily validations
%
h = subplot(3,2,1);

% draw
hold(h,'on');

	bar(h,(nv_w1+nv_w0)','stacked');

	y_lim = ylim;
	y_max = y_lim(2);

	draw_weekend_bg( h, weekend_bg, weekend_idx, y_max );

hold(h,'off');

% decoration
title(h,'SAC daily validations');

legend(h,'Active (status = 0)', ...
		  'Frozen (status = 10)', ...
		  'Stashed (status = 6)', ...
		  'Location','NorthWest');

axis(h,[0 (n_days+1) 0 y_max]);
xlabel(h,'Date');
grid(h,'on');
set(h,'XTick',find(monday_idx));
set(h,'XTickLabel',monday_str);


%% Daily effective validations (w = 1) for new cubes
%
h = subplot(3,2,2);

% draw
hold(h,'on');

	bar(h,(new_nv_w1)','stacked');
	draw_weekend_bg( h, weekend_bg, weekend_idx, y_max );

hold(h,'off');

% decoration
title(h,'SAC daily validations with weight=1 for new cubes');

legend(h,'Active (status = 0)', ...
		  'Frozen (status = 10)', ...
		  'Stashed (status = 6)', ...
		  'Location','NorthWest');

axis(h,[0 (n_days+1) 0 y_max]);
xlabel(h,'Date');
grid(h,'on');
set(h,'XTick',find(monday_idx));
set(h,'XTickLabel',monday_str);


%% Daily cubes
%
h = subplot(3,2,3);

% draw
hold(h,'on');

	bar(h,nt','stacked');

	y_lim = ylim;
	y_max = y_lim(2);

	draw_weekend_bg( h, weekend_bg, weekend_idx, y_max );

hold(h,'off');

% decoration
title(h,'SAC daily cubes');

legend(h,'Active (status = 0)', ...
		  'Frozen (status = 10)', ...
		  'Stashed (status = 6)', ...
		  'Location','NorthWest');

axis(h,[0 (n_days+1) 0 y_max]);
xlabel(h,'Date');
grid(h,'on');
set(h,'XTick',find(monday_idx));
set(h,'XTickLabel',monday_str);


%% Daily new cubes
%
h = subplot(3,2,4);

% draw
hold(h,'on');

	bar(h,new_nt','stacked');
	draw_weekend_bg( h, weekend_bg, weekend_idx, y_max );	

hold(h,'off');

% decoration
title(h,'SAC daily NEW cubes');

legend(h,'Active (status = 0)', ...
		  'Frozen (status = 10)', ...
		  'Stashed (status = 6)', ...
		  'Location','NorthWest');

axis(h,[0 (n_days+1) 0 y_max]);
xlabel(h,'Date');
grid(h,'on');
set(h,'XTick',find(monday_idx));
set(h,'XTickLabel',monday_str);


%%
%
h = subplot(3,2,5);

% draw
hold(h,'on');

	bar(h,nu');
	plot(h,sum(nv,1)./nu,'-or');
	plot(h,sum(nv,1)./sum(nt,1),'-og');
	
	y_lim = ylim;
	y_max = y_lim(2);

	draw_weekend_bg( h, weekend_bg, weekend_idx, y_max );

hold(h,'off');

% decoration
title(h,'Number of SAC daily challengers');

axis(h,[0 (n_days+1) 0 y_max]);
xlabel(h,'Date');
grid(h,'on');
set(h,'XTick',find(monday_idx));
set(h,'XTickLabel',monday_str);

legend(h,'Participants', ... 
		 'Average number of validations per participant', ...
		 'Average number of validations per cube', ...
		 'Location','NorthWest');


%%
%
h = subplot(3,2,6);

% draw
hold(h,'on');

	plot(h,sum(new_nv,1)./nu,'-or');
	plot(h,sum(new_nv_w1,1)./sum(new_nt,1),'-og');

	draw_weekend_bg( h, weekend_bg, weekend_idx, y_max );	

hold(h,'off');

% decoration

axis(h,[0 (n_days+1) 0 y_max]);
xlabel(h,'Date');
grid(h,'on');
set(h,'XTick',find(monday_idx));
set(h,'XTickLabel',monday_str);

legend(h,'Average number of validations per participant', ...
		 'Average number of validations with weight=1 per new cube', ...
		 'Location','NorthEast');

end


function draw_weekend_bg( h, weekend_bg, weekend_idx, y_max )

switch( weekend_bg )
case 'bar'
	B = bar(h,weekend_idx*y_max,'r','EdgeColor','none');
	ch = get(B,'child');
	set(ch,'facea',0.1);	
case 'line'

end

end