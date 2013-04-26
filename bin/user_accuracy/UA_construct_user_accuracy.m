function [UA] = UA_construct_user_accuracy( savePath, seed, DB_MAPs, cellIDs, period )

%% Argument validation
%
if( ~exist('seed','var') )
	seed = false;
end
if( ~exist('cellIDs','var') )
    cellIDs = [0];
end
if( ~exist('period','var') )
    period.since = '';
    period.until = '';
end


%% Construct DB MAPs
%
if( ~exist('DB_MAPs','var') )
	[DB_MAP_path] = DB_get_DB_MAP_path();
	[DB_MAPs] = DB_construct_DB_MAPs( DB_MAP_path, true, cellIDs, period );
end


%% Process user accuracy
%
[UA] = UA_process_user_accuracy( DB_MAPs, seed );


%% Output the result into a file
%
cellIDs_str = regexprep(num2str(unique(cellIDs)),' +','_');
fileName = sprintf('UA__cell_%s',cellIDs_str);
[period_suffix] = get_period_suffix( period );
fileName = [fileName period_suffix '.mat'];
save([savePath '/' fileName],'UA');

end