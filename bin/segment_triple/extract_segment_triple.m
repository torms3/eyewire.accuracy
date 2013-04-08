function [triples] = extract_segment_triple( cell, unions, consensus )

%% MySQL
addpath './mysql/';

mysql( 'open', '127.0.0.1:13306', 'omnidev', 'we8pizza' );
mysql( 'use omniweb' );

% validations
query_string = ['SELECT tasks.id, tasks.seeds, validations.finish, validations.segments, validations.weight ' ...
                'FROM validations ' ...
                'INNER JOIN tasks ON validations.task_id=tasks.id ' ...
                'WHERE tasks.cell=%d and validations.status=0 and tasks.status=0 ' ...
                'ORDER BY tasks.id, validations.finish '];
query = sprintf( query_string, cell );
[id,seed,time,seg_str,weight] = mysql( query );

mysql( 'close' );

%% Union & Consensus
if( ~exist('unions','var') )
    unions = extract_union_segments( cell );
end
if( ~exist('consensus','var') )
   consensus = extract_consensus_segments( cell );
end
assert( isequal( unions.task_ids, consensus.task_ids ) );

%% Extract triples
unique_id = unique( id );
assert( isequal( unique_id, consensus.task_ids ) );

% For each task (cube)
num_id = numel(unique_id);
for i = 1:num_id
   
    task_id = unique_id(i);
    fprintf( '%dth cube (task_id=%d) is now processing...\n', i, task_id );
    
    % union, consensus, and seed for this task (cube)
    union_seg = unions.segments{i};
    consensus_seg = consensus.segments{i};
    seed_seg_string = seed{find(id == task_id,1)};
    seed_seg = webtasks_segstr2seg( seed_seg_string, 0, 1 );
    
    union_seg = setdiff( union_seg, seed_seg );
    consensus_seg = setdiff( consensus_seg, seed_seg );

    % array for tracing (m,n)
    selected = zeros( 1, numel(union_seg) );
    
    % sigma
    [~,ia,~] = intersect( union_seg, consensus_seg );
    sigma = zeros( 1, numel(union_seg) );
    sigma(ia) = 1;
    
    % get segment strings for this task (cube)
    seg_strings = seg_str(id == task_id);
    weights = weight(id == task_id);
    assert( numel(seg_strings) == numel(weights) );
    
    % whether or not GrimReaper intervened this task (cube)
    GrimReaper = 0;
    if( nnz(weights > 1) > 0 )
        GrimReaper = 1;
    end

    % triples
    num_seg = numel(seg_strings);
    triples = zeros(num_seg,num_seg + 1,2);
    
    % for each segment (validation)
    m = 0;    
    for j = 1:num_seg
                       
        seg = webtasks_segstr2seg( seg_strings{j}, 0, 1 );
        
        % compare seg and union
        [~,ia,~] = intersect( union_seg, seg );
        
        % update selected
        selected(ia) = selected(ia) + 1;
        
        % extract (m,n,sigma) triples
        m = m + 1;        
        num_triple = numel(selected);
        for k = 1:num_triple
                        
            n = selected(k);            
            sig = sigma(k);
            
            triples(m,n+1,sig+1) = triples(m,n+1,sig+1) + 1;
            
        end        

    end

    data_path = './data/triples/';
    file_name = sprintf('cell_%d_task_%d.dat', cell, task_id);
    dlmwrite([data_path file_name], triples);

    if( GrimReaper )
        dlmwrite([data_path 'hotspots/' file_name], triples);
    end
    
end

end