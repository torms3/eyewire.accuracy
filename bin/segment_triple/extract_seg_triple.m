function extract_seg_triple( cell, MAP_t_info, MAP_v_info, MAP_vol_info )

%% Prerequisites
if( ~exist('cell','var') )
    return;
end

if( ~exist('MAP_v_info','var') )
   MAP_v_info = extract_validation_info( cell );
end

if( ~exist('MAP_t_info','var') )
   MAP_t_info = extract_task_info( cell );
end

if( ~exist('MAP_vol_info','var') )
   MAP_vol_info = extract_volume_info( cell );
end

%% Extract triples

% cube-wise processing
task_ids = MAP_t_info.keys;
for i = 1:MAP_t_info.Count
   
    task_id = task_ids{i};
    task_info = MAP_t_info(task_id);
    channel_id = task_info.channel_id;
    volume_info = MAP_vol_info(channel_id);
    n_seg = get_total_num_of_segments( volume_info );

    fprintf( '%dth cube (task_id=%d) is now processing...\n', i, task_id );
    
    % union, consensus, and seed for this task (cube)
    consensus_seg   = task_info.consensus;
    union_seg       = task_info.union;
    seed_seg        = task_info.seed;

    % number of true negative segments for this cube
    n_tn_seg = n_seg - numel(union_seg);
    
    % do not consider the seed segments
    consensus_seg   = setdiff( consensus_seg, seed_seg );
    union_seg       = setdiff( union_seg, seed_seg );    

    % array for tracing (m,n)
    selected = zeros(1,numel(union_seg));
    
    % sigma
    [~,ia,~] = intersect( union_seg, consensus_seg );
    sigma = zeros(1,numel(union_seg));
    sigma(ia) = 1;
    
    % whether or not GrimReaper intervened this task (cube)
    hotspot = 0;

    % triples
    v_ids = task_info.validation_ids;
    nv = numel(v_ids);
    assert( nv > 0 );
    triples = zeros(nv,nv+1,2);
    
    % for each segment (validation)
    m = 0;    
    for j = 1:nv

        v_id = v_ids(j);
        validation_info = MAP_v_info(v_id);         
        seg = validation_info.segments;

        % whether or not GrimReaper intervened this task (cube)
        % username = GrimReaper, id = 19401
        if( validation_info.user_id == 19401 )
            hotspot = 1;
        end
        
        % compare seg and union
        [~,ia,~] = intersect( union_seg, seg );
        
        % update selected
        selected(ia) = selected(ia) + 1;
        
        % extract (m,n,sigma) triples
        m = m + 1;
        n_triple = numel(selected);
        for k = 1:n_triple
                        
            n = selected(k);
            sig = sigma(k);
            
            triples(m,n+1,sig+1) = triples(m,n+1,sig+1) + 1;
            
        end

        % batch processing of true negative segments
        triples(m,0+1,0+1) = triples(m,0+1,0+1) + n_tn_seg;

    end

    data_path = './data/seg_triple/';
    file_name = sprintf('cell_%d_task_%d.dat', cell, task_id);
    dlmwrite([data_path file_name], triples);

    if( hotspot == 1 )
        dlmwrite([data_path 'hotspots/' file_name], triples);
    end
    
end

end