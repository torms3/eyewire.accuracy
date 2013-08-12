function DB_extract_segment_info( T, VOL )

%% Cube-wise processing
%
keys 	= T.keys;
vals 	= T.values;
parfor i = 1:T.Count

	tID 	= keys{i};
	tInfo 	= vals{i};
	fprintf( 'Extracting segment size information for %dth cube (task_id=%d)...\n', i, tID );

	% extract segment size information
	chID 	= tInfo.chID;
	volInfo = VOL(chID);
	seg 	= tInfo.union;
	
	[segSize,nSeg] = get_size_of_segments( volInfo, seg );

	% update task information
	tInfo.seg_size = segSize;
	T(tID) = tInfo;

	% update volume information
	volInfo.n_seg = nSeg;
	VOL(chID) = volInfo;

end

end