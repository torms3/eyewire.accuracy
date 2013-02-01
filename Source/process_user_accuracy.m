function [output_matrix] = process_user_accuracy( cell, MAP_u_info, MAP_v_info, MAP_t_info )

%%
%% Prerequisites
%%

if( ~exist('cell','var') )
    return;
end

if( ~exist('MAP_u_info','var') )
    MAP_u_info = extract_user_info( cell );
end

if( ~exist('MAP_v_info','var') )
   MAP_v_info = extract_validation_info( cell );
end

if( ~exist('MAP_t_info','var') )
   MAP_t_info = extract_task_info( cell );
end

%%
%% Process user accuracy
%%

field_dim = 9;
output_matrix = zeros( MAP_u_info.Count, field_dim );

% user-wise processing
user_ids = MAP_u_info.keys;
for i = 1:MAP_u_info.Count
   
    user_id = user_ids{i};

    fprintf( '%dth user (user_id=%d) is now processing...\n', i, user_id );
    [user_accuracy_info] = process_each_user( MAP_u_info(user_id), MAP_v_info, MAP_t_info );

    output_matrix(i,1) = user_id;
    output_matrix(i,2) = user_accuracy_info.tp;
    output_matrix(i,3) = user_accuracy_info.fn;
    output_matrix(i,4) = user_accuracy_info.fp;
    output_matrix(i,5) = user_accuracy_info.sc;
    output_matrix(i,6) = user_accuracy_info.nv;
    output_matrix(i,7) = user_accuracy_info.tpv;
    output_matrix(i,8) = user_accuracy_info.fnv;
    output_matrix(i,9) = user_accuracy_info.fpv;
    
end

%%
%% Output the result into a file
%%

file_path = './data/';
file_name = sprintf( 'user_accuracy__cell_%d.dat', cell );
dlmwrite( [file_path file_name], output_matrix );

end