function [UA] = UA_process_user_accuracy( DB_MAPs, seed )

%% Argument validation
%
if( ~exist('seed','var') )
    seed = false;
end


%% Extract hotspot cube IDs
%
[hotspot_IDs,~] = get_VT_hotspots( DB_MAPs.V, DB_MAPs.T );


%% Process user accuracy
%
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
        
    [UA_info] = process_each_user( uID, DB_MAPs, hotspot_IDs, seed );
      
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

end