% DB_MAPs
cell_IDs = [-34];
DB_MAPs = cell(3,1);
[DB_MAPs{1}] = SAC_construct_DB_MAPs( false, false, cell_IDs, 0 );
[DB_MAPs{2}] = SAC_construct_DB_MAPs( false, false, cell_IDs, 10 )
[DB_MAPs{3}] = SAC_construct_DB_MAPs( false, false, cell_IDs, 6 );

% daily stat
[daily_stat] = get_SAC_daily_stat( DB_MAPs );

% plot
plot_SAC_daily_validations( daily_stat );