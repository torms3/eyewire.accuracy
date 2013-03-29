function [VOL] = DB_extract_segment_number_info( VOL )

%% Volume-wise processing
%
keys 	= VOL.keys;
vals 	= VOL.values;
for i = 1:VOL.Count

	% key & value
	chID 	= keys{i};
	volInfo = vals{i};
	fprintf('Extracting # of segment information for %dth volume (chID=%d)...\n',i,chID);

	% extract segment number information
	volPath = volInfo.path;
	volInfo.n_seg = get_total_num_of_segments( volPath );

	% update volume information
	VOL(chID) = volInfo;

end

end