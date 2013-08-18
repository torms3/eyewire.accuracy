
%% Period
%
from = datenum('2013-08-04','yyyy-mm-dd');
to = datenum('2013-08-04','yyyy-mm-dd');
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
	day = datestr(from+i,'yyyy-mm-dd');
	period.until = sprintf('''%s''',[day ' ' midnight]);
	disp(period.until);

	% accuracy
	[STAT] = extract_accuracy( period );

	% results
	stats{i} = EyeWireSupport_extract_accuracy_stats( STAT );

end