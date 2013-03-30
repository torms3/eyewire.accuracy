function [T] = DB_extract_segment_size_info( T, VOL )

%% Cube-wise processing
%
keys 	= T.keys;
vals 	= T.values;
for i = 1:T.Count

	tID 	= keys{i};
	tInfo 	= vals{i};
	fprintf( 'Extracting segment size information for %dth cube (task_id=%d)...\n', i, tID );

	% extract segment size information
	chID 	= tInfo.chID;
	volInfo = VOL(chID);
	seg 	= tInfo.union;
	seg_size = get_size_of_segments( volInfo, seg );

	% update task information
	tInfo.seg_size = seg_size;
	T(tID) = tInfo;

end

end