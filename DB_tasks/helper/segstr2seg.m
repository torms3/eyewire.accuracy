function [seg] = segstr2seg( str )

%% Argument validation
%
if( isempty(str) || strcmp(str,'[]') || strcmp(str,'{}') )
    seg=[];
    return;
end
if (strcmp(str,'null'))
    seg=[];
    return;
end


%% Segment extraction
%
pl = findstr(str,'{');
pr = findstr(str,'}');
str = str(pl+1:pr-1);
C = textscan(str,'"%d":%*s','Delimiter',',');
seg = cell2mat(C)';

end