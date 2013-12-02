function [stat] = NCM_extract_user_stat( dataPath )

	stat.uIDs  = [];
	stat.nCube = [];

	% DB_MAPs files are assuemd to be processed 
	% in an ascending order of cell numbers
	data_list = dir(dataPath);
	for i = 1:numel(data_list)

		% skip non-file
		if( data_list(i).isdir )
			continue;
		end

		% load file
		fileName = data_list(i).name;
		disp([fileName ' is now being processed...']);
		load([dataPath '/' fileName]);

		% extract user-segment matrix
		% skipV0 = false;
		% [data] = NUSM_create_user_segment_matrix( DB_MAPs, skipV0 );

		% extract stat
		%	# cubes
		keys = DB_MAPs.U.keys();
		vals = DB_MAPs.U.values();

		uIDs  = cell2mat(keys);
		nCube = extractfield(cell2mat(vals),'nv');

		assert(issorted(uIDs));
		assert(issorted(stat.uIDs));

		ia = ismember(stat.uIDs,uIDs);
		ib = ismember(uIDs,stat.uIDs);
		if any(ib)
			stat.nCube(ia) = stat.nCube(ia) + nCube(ib);		
			stat.uIDs = [stat.uIDs uIDs(~ib)];
			stat.nCube = [stat.nCube nCube(~ib)];
		else
			stat.uIDs = [stat.uIDs uIDs];
			stat.nCube = [stat.nCube nCube];	
		end
		[stat.uIDs,idx] = sort(stat.uIDs,'ascend');
		stat.nCube = stat.nCube(idx);

	end

end