function [n_seg] = get_total_num_of_segments( vol_path )

metadata_file = '/projectMetadata.yaml';

tokens = textread([vol_path metadata_file],'%s');
indices = strmatch('Num',tokens,'exact');
next_tokens = tokens(indices+1);
idx = strmatch('Segments:',next_tokens,'exact');

n_seg_str = tokens(indices(idx)+2);
n_seg = str2num(n_seg_str{1});

end