function [file_name] = make_UA_file_name( cell_IDs, period )

%% Argument validation
% 
if( ~exist('cell_IDs','var') )
    cell_IDs = [0];
end
if( ~exist('period','var') )
    period.since = '';
    period.until = '';
end


% file name
cell_IDs_str = regexprep(num2str(unique(cell_IDs)),' +','_');
file_name = sprintf('UA__cell_%s',cell_IDs_str);

% period suffix
[period_suffix] = get_period_suffix( period );
file_name = [file_name period_suffix '.mat'];

end