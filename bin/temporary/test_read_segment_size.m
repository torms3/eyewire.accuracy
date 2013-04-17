
T = DB_MAPs.T;
VOL = DB_MAPs.VOL;

size_sum = 0;

keys 	= T.keys;
vals 	= T.values;
for i = 1:T.Count

	tID = keys{i};
	fprintf('(%d/%d) tID = %d is now processing...\n',i,T.Count,tID);
	tInfo = vals{i};	
	volInfo = VOL(tInfo.chID);
	c_seg = tInfo.consensus;

	size_sum = size_sum + sum(get_size_of_segments( volInfo, c_seg ));

	% [size_of_seg1] = get_size_of_segments( volInfo, c_seg );
	% [size_of_seg2] = get_size_of_segments_old( volInfo, c_seg );

	% if( ~isequal(size_of_seg1,size_of_seg2) )

	% 	disp(size_of_seg1);
	% 	disp(size_of_seg2);

	% 	assert( false );

	% end

end

disp(size_sum);