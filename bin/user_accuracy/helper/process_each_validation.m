function [VA] = process_each_validation( vInfo, tInfo, include_seed )

% initialization
% VA stands for Validation Accuracy
VA.tp 	= [];
VA.fn 	= [];
VA.fp 	= [];
VA.tn 	= [];

% validation segments
seg 	= vInfo.segs;

% task segment info
u_seg 	= tInfo.union;
c_seg 	= tInfo.consensus;
seed 	= tInfo.seed;

% do not consider seed segments
if( include_seed )	
	c_seg 	= union(c_seg,seed);
else
	u_seg 	= setdiff(u_seg,seed);
	c_seg 	= setdiff(c_seg,seed);
	seg 	= setdiff(seg,seed);
end

% compare
VA.tp 	= intersect(seg,c_seg);
VA.fn 	= setdiff(c_seg,seg);
VA.fp 	= setdiff(seg,c_seg);
VA.tn 	= setdiff(u_seg,[c_seg VA.fp]);	% no intersect between c_seg and VA.fp

end