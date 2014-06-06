function [] = compute_confusion_info( MAPs )

	%% Cell-type information
	[MAP_celltype] = DB_create_MAP_celltype();

	%% Validation-wise processing
	vIDs = cell2mat(MAPs.V.keys);
	nv = numel(vIDs);
	for i = 1:nv

	    vID     = vIDs(i);
	    vInfo   = MAPs.V(vID);

	    tID     = vInfo.tID;
	    tInfo   = MAPs.T(tID);

	    cellID	= tInfo.cell;
	    SAC		= strcmp(MAP_celltype(cellID),'sac');

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

	    % SAC or non-SAC
	    vInfo.SAC = SAC;

	    MAPs.V(vID) = vInfo;
	    
	end

end