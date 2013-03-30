function [save_dir] = USM_make_save_dir_name( cell_ID, period )

%% Argument validation
% 
if( ~exist('cell_ID','var') )
    cell_ID = 0;
end
if( ~exist('period','var') )
    period.since = '';
    period.until = '';
end


% prefix
prefix = sprintf('USM__cell_%d',cell_ID);

% period suffix
[period_suffix] = get_period_suffix( period );
save_dir = [prefix period_suffix];

end