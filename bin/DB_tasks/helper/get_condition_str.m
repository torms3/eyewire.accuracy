function [cond_str] = get_condition_str( field, value, avoid )

cond_str = '';

%% Argument validation
%
if( ~exist('value','var') )
	value = [];
end
if( ~exist('avoid','var') )
	avoid = [];
end
value = unique(value);
avoid = unique(avoid);


% desired values
if( ~isempty(value) )
	str = '(';
	for i = 1:numel(value)
		str = [str sprintf([field '=%d '],value(i))];
	end
	str(end) = ')';
	str = regexprep(str,' +',' OR ');
	cond_str = [str ' '];
end

% values to avoid
if( ~isempty(avoid) )
	str = '(';
	for i = 1:numel(avoid)
		str = [str sprintf([field '!=%d '],avoid(i))];
	end
	str(end) = ')';
	str = regexprep(str,' +',' AND ');
	
	if( isempty(cond_str) )
		cond_str = [str ' '];
	else
		cond_str = ['(' cond_str 'AND ' str ') '];
	end	
end

end