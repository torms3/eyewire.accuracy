function [cube_accuracy_info] = process_each_cube( MAP_t_info, task_id, MAP_v_info )

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

% whether or not the cube is intervened by GrimReaper
hotspot = 0;

task_info = MAP_t_info(task_id);
v_ids = task_info.validation_ids;
nv = numel( v_ids );
for i = 1:nv

    v_id = v_ids(i);
    
    [match,miss,extra] = process_each_validation( MAP_v_info(v_id), MAP_t_info );

    % do not consider the validations submitted by GrimReaper
    % username = GrimReaper, id = 19401
    if( MAP_v_info(v_id).user_id == 19401 )
        hotspot = 1;
        continue;
    end

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

cube_accuracy_info.tp = tp;
cube_accuracy_info.fn = fn;
cube_accuracy_info.fp = fp;
cube_accuracy_info.sc = sc;
cube_accuracy_info.nv = nv;
cube_accuracy_info.tpv = tpv;
cube_accuracy_info.fnv = fnv;
cube_accuracy_info.fpv = fpv;

% [1/31/2013 kisuklee] TODO
% tentative code
cube_accuracy_info.hotspot = hotspot;

end