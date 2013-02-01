function [user_accuracy_info] = process_each_user( user_info, MAP_v_info, MAP_t_info )

% number of segments
tp = 0;
fn = 0;
fp = 0;

% number of voxels (segment size)
tpv = 0;
fnv = 0;
fpv = 0;

% score
sc = 0;

v_ids = user_info.validation_ids;
nv = numel( v_ids );
for i = 1:nv

    v_id = v_ids(i);      
    
    [match,miss,extra] = process_each_validation( MAP_v_info(v_id), MAP_t_info );

    % number of segments
    tp = tp + numel( match );
    fn = fn + numel( miss );
    fp = fp + numel( extra );

    % number of voxels (segment size)
    % ch_id = user_stat.channel_ids(i);
    % tpv = tpv + get_segments_size( ch_id, match );
    % fnv = fnv + get_segments_size( ch_id, miss );
    % fpv = fpv + get_segments_size( ch_id, extra );

    % score
    sc = sc + MAP_v_info(v_id).score;
    
end

user_accuracy_info.tp = tp;
user_accuracy_info.fn = fn;
user_accuracy_info.fp = fp;
user_accuracy_info.tpv = tpv;
user_accuracy_info.fnv = fnv;
user_accuracy_info.fpv = fpv;
user_accuracy_info.sc = sc;
user_accuracy_info.nv = nv;

end