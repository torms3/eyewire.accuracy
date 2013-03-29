function [file_name] = make_DB_MAPs_file_name( cell_ID, period )

%% Argument validation
% 
if( ~exist('cell_ID','var') )
    cell_ID = 0;
end
if( ~exist('period','var') )
    period.since = '';
    period.until = '';
end


% file name
file_name = sprintf('DB_MAPs__cell_%d',cell_ID);

% period suffix
[period_suffix] = get_period_suffix( period );
file_name = [file_name,period_suffix,'.mat'];

end