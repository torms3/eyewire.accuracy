function [output_matrix] = UA_process_user_accuracy( save_path, DB_MAPs, cell_IDs, period )

%% Argument validation
%
if( ~exist('cell_IDs','var') )
    cell_IDs = [0];
end

if( ~exist('period','var') )
    period.since = '';
    period.until = '';
end

if( ~exist('DB_MAPs','var') )
    [DB_MAP_path] = DB_get_DB_MAP_path();
    [DB_MAPs] = DB_construct_DB_MAPs( DB_MAP_path, true, false, cell_IDs, period );
end


%% Extract hotspot cube IDs
%
[hotspot_IDs,~] = get_VT_hotspots( DB_MAPs.V, DB_MAPs.T );


%% Process user accuracy
%
field_dim = 9;
output_matrix = zeros(DB_MAPs.U.Count,field_dim);

% user-wise processing
keys    = DB_MAPs.U.keys;
for i = 1:DB_MAPs.U.Count
   
    uID = keys{i};
    fprintf('%dth user (uID=%d) is now processing...\n',i,uID);
        
    [UA_info] = process_each_user( DB_MAPs.U(uID), DB_MAPs.V, ...
                              DB_MAPs.T, DB_MAPs.VOL, hotspot_IDs );
    
    output_matrix(i,1) = uID;
    output_matrix(i,2) = UA_info.tp;
    output_matrix(i,3) = UA_info.fn;
    output_matrix(i,4) = UA_info.fp;
    output_matrix(i,5) = UA_info.nv;
    output_matrix(i,6) = UA_info.tpv;
    output_matrix(i,7) = UA_info.fnv;
    output_matrix(i,8) = UA_info.fpv;
    
    % # of hotspots
    output_matrix(i,9) = UA_info.hot;
    
end

%% Output the result into a file
%
cell_IDs_str = regexprep(num2str(unique(cell_IDs)),' +','_');
file_name = sprintf('user_accuracy__cell_%s.dat',cell_IDs_str);
dlmwrite([save_path file_name],output_matrix);

end