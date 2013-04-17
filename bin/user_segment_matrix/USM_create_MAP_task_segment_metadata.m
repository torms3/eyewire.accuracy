function [MAP_t_meta] = USM_create_MAP_task_segment_metadata( T, VOL )
%% Argument description
%
%	T: 		MAP_t_info
%	VOL: 	MAP_vol_info
%


%% Option
%
include_seed = false;


%% Global offset
%
% s1 	sigma = 1
% s0 	sigma = 0, among voted segments
% s00 	sigma = 0
%
offset 		= 0;
offset_s1 	= 0;
offset_s0 	= 0;
offset_s00 	= 0;


%% Cube-wise processing
% 
keys 	= T.keys;
vals	= T.values;
for i = 1:T.Count

	tID = keys{i};

	% fprintf( '%dth cube (t_id=%d) is now processing...\n', i, tID );

	% total number of segments for this cube
	tInfo 	= vals{i};
	chID	= tInfo.chID;
	n_seg 	= VOL(chID).n_seg;

	% seed consideration
	u_seg	= tInfo.union;		% u_seg: union segments
	c_seg	= tInfo.consensus;	% c_seg: consensus segments
	seed 	= tInfo.seed;		% seed: seed segments
	
	% all set operations result in sorted lists
	if( include_seed )
		seg_s1	= union(c_seg,seed);
	else
		seg_s1	= setdiff(c_seg,seed);
	end		
	seg_s00	= setdiff(1:n_seg,union(c_seg,seed));
	seg_s0	= intersect(seg_s00,u_seg);

	% data element
	DE{i}.n_seg 	= n_seg;
	DE{i}.seg_s1 	= seg_s1;
	DE{i}.seg_s0 	= seg_s0;
	% DE{i}.seg_s00 	= seg_s00;
	DE{i}.seg_s00 	= [];	% for saving memory

	% [04/16/2013 kisuklee] seed index
	if( include_seed )
		DE{i}.seed 		= seed;
		DE{i}.seed_idx 	= ismember(seg_s1,seed);
	end

	% [03/26/2013 kisuklee] segment volume
	[~,idx,~] = intersect(u_seg,seg_s1);
	segvol_s1 = tInfo.seg_size(idx);
	if( isempty(segvol_s1) )
		segvol_s1 = [];
	end
	assert( numel(segvol_s1) == numel(seg_s1) );
	
	[~,idx,~] = intersect( u_seg, seg_s0 );
	segvol_s0 = tInfo.seg_size(idx);
	if( isempty(segvol_s0) )
		segvol_s0 = [];
	end
	assert( numel(segvol_s0) == numel(seg_s0) );
	
	DE{i}.segvol_s1 = segvol_s1;
	DE{i}.segvol_s0 = segvol_s0;

	% offset information
	if( include_seed )
		offset	= offset + n_seg;
	else
		offset	= offset + (n_seg - numel(seed));
	end
	offset_s1 	= offset_s1 + numel(seg_s1);
	offset_s0 	= offset_s0 + numel(seg_s0);
	offset_s00 	= offset_s00 + numel(seg_s00);

	% next data element
	DE{i+1}.offset 	 	= offset;	
	DE{i+1}.offset_s1  	= offset_s1;
	DE{i+1}.offset_s0  	= offset_s0;
	DE{i+1}.offset_s00 	= offset_s00;

end

DE{1}.offset 	 	= 0;
DE{1}.offset_s1  	= 0;
DE{1}.offset_s0  	= 0;
DE{1}.offset_s00	= 0;

% [2/9/2013 kisuklee]
% vulnerable code
% 	MAP_t_meta(0) is reserved for information about
%	the total number of segments.
%
%		# of segments w/o seed: 	MAP_t_meta(0).offset
%		# of segments w/ sigma = 1: MAP_t_meta(0).offset_s1
%		# of segments w/ sigma = 0: MAP_t_meta(0).offset_s0
%
keys{end+1}		= 0;
DE{end}.seg_s1  = [];
DE{end}.seg_s0  = [];
DE{end}.seg_s00 = [];


%% Create MAP for task segment metadata
%
MAP_t_meta = containers.Map( keys, DE );

end