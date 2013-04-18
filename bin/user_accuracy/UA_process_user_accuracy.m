function [UA] = UA_process_user_accuracy( savePath, DB_MAPs, cell_IDs, period )

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
    [DB_MAPs] = DB_construct_DB_MAPs( DB_MAP_path, true, cell_IDs, period );
end


%% Extract hotspot cube IDs
%
[hotspot_IDs,~] = get_VT_hotspots( DB_MAPs.V, DB_MAPs.T );


%% Process user accuracy
%
field_dim = 9;
M = zeros(DB_MAPs.U.Count,field_dim);

% [04/17/2013 kisuklee]
% New candidate data structure
nUsers  = DB_MAPs.U.Count;
UA.uID  = zeros(1,nUsers);
UA.nv   = zeros(1,nUsers);
UA.tp   = zeros(1,nUsers);
UA.fn   = zeros(1,nUsers);
UA.fp   = zeros(1,nUsers);
UA.tn   = zeros(1,nUsers);
UA.tpv  = zeros(1,nUsers);
UA.fnv  = zeros(1,nUsers);
UA.fpv  = zeros(1,nUsers);
UA.tnv  = zeros(1,nUsers);
UA.hot  = zeros(1,nUsers);


%% User-wise processing
%
keys    = DB_MAPs.U.keys;
for i = 1:DB_MAPs.U.Count
   
    uID = keys{i};
    fprintf('%dth user (uID=%d) is now processing...\n',i,uID);
        
    [UA_info] = process_each_user( uID, DB_MAPs, hotspot_IDs );
    
    M(i,1) = uID;
    M(i,2) = UA_info.tp;
    M(i,3) = UA_info.fn;
    M(i,4) = UA_info.fp;
    M(i,5) = UA_info.nv;
    M(i,6) = UA_info.tpv;
    M(i,7) = UA_info.fnv;
    M(i,8) = UA_info.fpv;
    M(i,9) = UA_info.hot;   % # of hotspots

    UA.uID(i) = uID;
    UA.nv(i)  = UA_info.nv;    
    UA.tp(i)  = UA_info.tp;
    UA.fn(i)  = UA_info.fn;
    UA.fp(i)  = UA_info.fp;
    UA.tn(i)  = UA_info.tn;
    UA.tpv(i) = UA_info.tpv;
    UA.fnv(i) = UA_info.fnv;
    UA.fpv(i) = UA_info.fpv;
    UA.tnv(i) = UA_info.tnv;    
    UA.hot(i) = UA_info.hot;
    
end


%% Output the result into a file
%
cell_IDs_str = regexprep(num2str(unique(cell_IDs)),' +','_');
fileName = sprintf('user_accuracy__cell_%s.dat',cell_IDs_str);
dlmwrite([savePath '/' fileName],M);

end