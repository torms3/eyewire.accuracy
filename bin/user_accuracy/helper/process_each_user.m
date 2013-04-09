function [UA_info] = process_each_user( uInfo, V, T, VOL, hotspot_IDs )

% number of segments
tp = 0;
fn = 0;
fp = 0;

% number of voxels (segment volume)
tpv = 0;
fnv = 0;
fpv = 0;

% number of hotspot cubes done by this user
hot = 0;

vIDs = uInfo.vIDs;
nv = numel(vIDs);
for i = 1:nv

    vID     = vIDs(i);      
    vInfo   = V(vID);

    tID     = vInfo.tID;
    tInfo   = T(tID);

    [match,miss,extra] = process_each_validation( vInfo, tInfo );

    % number of segments
    tp = tp + numel( match );
    fn = fn + numel( miss );
    fp = fp + numel( extra );

    % number of voxels (segment volume)    
    % chID = T(tID).channel_id;
    % volInfo = VOL(chID);
    % try
        % tpv = tpv + sum( get_size_of_segments( volInfo, match ) );
        % fnv = fnv + sum( get_size_of_segments( volInfo, miss ) );
        % fpv = fpv + sum( get_size_of_segments( volInfo, extra ) );
    % catch err
    %     error('invalid seg ID: user=%s vID=%d tID=%d chID=%d',cell2mat(uInfo.username),v_id,tID,chID);
    % end
    
    % u_seg = tInfo.union;
    % [~,idx,~] = intersect( u_seg, match );
    % tpv = tpv + sum(tInfo.seg_size(idx));
    % [~,idx,~] = intersect( u_seg, miss );
    % fnv = fnv + sum(tInfo.seg_size(idx));
    % [~,idx,~] = intersect( u_seg, extra );
    % fpv = fpv + sum(tInfo.seg_size(idx));
    u_seg = tInfo.union;
    idx = ismember( u_seg, match );
    tpv = tpv + sum(tInfo.seg_size(idx));
    idx = ismember( u_seg, miss );
    fnv = fnv + sum(tInfo.seg_size(idx));
    idx = ismember( u_seg, extra );
    fpv = fpv + sum(tInfo.seg_size(idx));

    % hotspot cubes
    if( ~isempty(find(hotspot_IDs == tID)) )
        hot = hot + 1;
    end
    
end

UA_info.tp = tp;
UA_info.fn = fn;
UA_info.fp = fp;
UA_info.nv = nv;
UA_info.tpv = tpv;
UA_info.fnv = fnv;
UA_info.fpv = fpv;
UA_info.hot = hot;

end