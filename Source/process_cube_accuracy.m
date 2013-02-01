function [output_matrix] = process_cube_accuracy( cell, MAP_t_info, MAP_v_info )

%%
%% Prerequisites
%%

if( ~exist('cell','var') )
    return;
end

if( ~exist('MAP_v_info','var') )
   MAP_v_info = extract_validation_info( cell );
end

if( ~exist('MAP_t_info','var') )
   MAP_t_info = extract_task_info( cell );
end

%%
%% Collect data about the votes for cubes
%%

field_dim = 7;
output_matrix = zeros( MAP_t_info.Count, field_dim );

% cube-wise processing
task_ids = MAP_t_info.keys;
for i = 1:MAP_t_info.Count
   
    task_id = task_ids{i};
    
    fprintf( '%dth cube (task_id=%d) is now processing...\n', i, task_id );
    [cube_accuracy_info] = process_each_cube( MAP_t_info, task_id, MAP_v_info );

    output_matrix(i,1) = task_id;
    output_matrix(i,2) = cube_accuracy_info.tp;
    output_matrix(i,3) = cube_accuracy_info.fn;
    output_matrix(i,4) = cube_accuracy_info.fp;
    output_matrix(i,5) = cube_accuracy_info.sc;
    output_matrix(i,6) = cube_accuracy_info.nv;
    
    % [1/31/2013 kisuklee] TODO
    % tentative code
    output_matrix(i,7) = cube_accuracy_info.hotspot;
    
end

%%
%% Output the result into a file
%%

file_path = './data/cube_accuracy/';
file_name = sprintf( 'cube_accuracy__cell_%d.dat', cell );
dlmwrite( [file_path file_name], output_matrix );

end