function [UA_info] = process_each_user( uID, DB_MAPs, hotspot_IDs, include_seed )

%% Argument validation
%
if( ~exist('include_seed','var') )
    include_seed = false;
end


U   = DB_MAPs.U;
T   = DB_MAPs.T;
V   = DB_MAPs.V;
VOL = DB_MAPs.VOL;

uInfo = U(uID);

% number of segments
tp = 0;
fn = 0;
fp = 0;
tn = 0;

% number of voxels (segment volume)
tpv = 0;
fnv = 0;
fpv = 0;
tnv = 0;

% number of hotspot cubes done by this user
hot = 0;


%% Validation-wise processing
%
vIDs = uInfo.vIDs;
nv = numel(vIDs);
for i = 1:nv

    vID     = vIDs(i);
    vInfo   = V(vID);

    tID     = vInfo.tID;
    tInfo   = T(tID);

    if tInfo.n_seg == 0
        continue;
    end

    % [match,miss,extra] = process_each_validation( vInfo, tInfo );
    [VA] = process_each_validation( vInfo, tInfo, include_seed );
    
    % number of segments
    tp = tp + numel(VA.tp);
    fn = fn + numel(VA.fn);
    fp = fp + numel(VA.fp);
    tn = tn + numel(VA.tn);

    % number of voxels (segment volume)    
    % chID = T(tID).chID;
    % volInfo = VOL(chID);
    % try
    %     tpv = tpv + sum( get_size_of_segments( volInfo, match ) );
    %     fnv = fnv + sum( get_size_of_segments( volInfo, miss ) );
    %     fpv = fpv + sum( get_size_of_segments( volInfo, extra ) );
    % catch err
    %     error('invalid seg ID: user=%s vID=%d tID=%d chID=%d',cell2mat(uInfo.username),v_id,tID,chID);
    % end

    u_seg = tInfo.union;    
    tpv = tpv + sum(tInfo.seg_size(ismember(u_seg,VA.tp)));
    fnv = fnv + sum(tInfo.seg_size(ismember(u_seg,VA.fn)));
    fpv = fpv + sum(tInfo.seg_size(ismember(u_seg,VA.fp)));
    tnv = tnv + sum(tInfo.seg_size(ismember(u_seg,VA.tn)));

    % hotspot cubes
    if( any(hotspot_IDs == tID) )
        hot = hot + 1;
    end
    
end

UA_info.nv  = nv;
UA_info.tp  = tp;
UA_info.fn  = fn;
UA_info.fp  = fp;
UA_info.tn  = tn;
UA_info.tpv = tpv;
UA_info.fnv = fnv;
UA_info.fpv = fpv;
UA_info.tnv = tnv;
UA_info.hot = hot;

end