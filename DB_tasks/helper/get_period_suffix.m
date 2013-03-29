function [period_suffix] = get_period_suffix( period )

%% Check period
% 
[b_since,b_until] = check_period( period );


%% Period suffix
%
period_suffix = '';

from_suffix = '';
if( b_since )
	C = textscan(period.since,'''%s %s''');
	from_suffix = sprintf('from_%s',cell2mat(C{1}));
	period_suffix = [period_suffix '_' from_suffix];
end

to_suffix = '';
if( b_until )
	C = textscan(period.until,'''%s %s''');
	to_suffix = sprintf('to_%s',cell2mat(C{1}));
	period_suffix = [period_suffix '_' to_suffix];
end

end