function [user_stat] = extract_user_stat( input_file )

% read file
M = dlmread( input_file );

% extract information
user_stat.original_matrix = M;
user_stat.id = M(:,1);
user_stat.tp = M(:,2);
user_stat.fn = M(:,3);
user_stat.fp = M(:,4);
user_stat.nv = M(:,5);
user_stat.tpv = M(:,6);
user_stat.fnv = M(:,7);
user_stat.fpv = M(:,8);
user_stat.hot = M(:,9);

end