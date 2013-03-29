function [seg] = extract_consensus( str, th )

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


%% Consensus extraction
%
pl = findstr(str,'{');
pr = findstr(str,'}');
str = str(pl+1:pr-1);
C = textscan(str,'"%d":%f','Delimiter',',');
seg  = C{1}';
prob = C{2}';
seg = seg(prob > th);
if( isempty(seg) )
	seg = [];
end

end