function [save_dir] = USM_make_save_dir_name( cell_IDs, period )

%% Argument validation
% 
if( ~exist('cell_IDs','var') )
    cell_IDs = [0];
end
if( ~exist('period','var') )
    period.since = '';
    period.until = '';
end


% prefix
cell_IDs_str = regexprep(num2str(unique(cell_IDs)),' +','_');
prefix = sprintf('USM__cell_%s',cell_IDs_str);

% period suffix
[period_suffix] = get_period_suffix( period );
save_dir = [prefix period_suffix];

end