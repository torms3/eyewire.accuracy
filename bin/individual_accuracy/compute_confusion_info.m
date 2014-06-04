function [] = compute_confusion_info( MAPs )

	%% Validation-wise processing
	vIDs = cell2mat(MAPs.V.keys);
	nv = numel(vIDs);
	for i = 1:nv

	    vID     = vIDs(i);
	    vInfo   = MAPs.V(vID);

	    tID     = vInfo.tID;
	    tInfo   = MAPs.T(tID);

	    if isempty(tInfo.seg_size)
	        continue;
	    end

	    include_seed = false;
	    [VA] = process_each_validation(vInfo,tInfo,include_seed);
	    
	    % number of segments
	    vInfo.tp = VA.tp;
	    vInfo.fn = VA.fn;
	    vInfo.fp = VA.fp;
	    vInfo.tn = VA.tn;
	    
	    u_seg = tInfo.union;
	    vInfo.tpv = sum(tInfo.seg_size(ismember(u_seg,VA.tp)));
	    vInfo.fnv = sum(tInfo.seg_size(ismember(u_seg,VA.fn)));
	    vInfo.fpv = sum(tInfo.seg_size(ismember(u_seg,VA.fp)));
	    vInfo.tnv = sum(tInfo.seg_size(ismember(u_seg,VA.tn)));

	    MAPs.V(vID) = vInfo;
	    
	end

end