
%% Period
%
from = datenum('2013-08-05','yyyy-mm-dd');
to = datenum('2013-08-11','yyyy-mm-dd');
midnight = '00:00:00';


%% For each day
%
nDays = numel(from:to);
stats = cell(nDays,1);
for i = 1:numel(from:to)

	% period
	day = datestr(from+i-1,'yyyy-mm-dd');
	period.since = sprintf('''%s''',[day ' ' midnight]);
	disp(period.since);
	day = datestr(fom+i,'yyyy-mm-dd');
	period.until = sprintf('''%s''',[day ' ' midnight]);
	disp(period.until);

	% accuracy
	[STAT] = extract_accuracy( period );

	% results
	stats{i}.username = extractfield( cell2mat(STAT.values), 'username' );
	stats{i}.nv = extractfield( cell2mat(STAT.values), 'nv' );
	stats{i}.tpv = extractfield( cell2mat(STAT.values), 'tpv' );
	stats{i}.fnv = extractfield( cell2mat(STAT.values), 'fnv' );
	stats{i}.fpv = extractfield( cell2mat(STAT.values), 'fpv' );
	stats{i}.v_prec = extractfield( cell2mat(STAT.values), 'v_prec' );
	stats{i}.v_rec = extractfield( cell2mat(STAT.values), 'v_rec' );
	stats{i}.v_fs = extractfield( cell2mat(STAT.values), 'v_fs' );

end