function [] = prepare_hierarchical_segmentation( DB_MAPs, save_path )

	T 	= DB_MAPs.T;
	VOL = DB_MAPs.VOL;

	%% Cube-wise processing
	%	
	keys 	= T.keys;
	tInfos 	= T.values;
	% for i = 1:T.Count
	for i = 1:10

		tID = keys{i};
		fprintf('(%d/%d) tID = %d is now processing...\n',i,T.Count,tID);
		tInfo = tInfos{i};
		chID = tInfo.chID;

		volInfo = VOL(chID);
		volPath = volInfo.path;

		%% Read MST data
		%		
		mst_file = 'mst.data';
		mid_path = '/users/_default/segmentations/segmentation1/segments';
		mst_path = [volPath mid_path '/' mst_file];
		mstEdges = read_mst( mst_path );

		%% Save MST data
		%
		save_dir = ['Cube_' num2str(tID)];
		full_path = [save_path '/' save_dir];
		mkdir(full_path);
		save([full_path '/mst.mat'],'mstEdges');

		%% Copy channel & segmentation data (mip-level 1)
		%
		chn_path = '/channels/channel1/1/volume.float.raw';
		seg_path = '/segmentations/segmentation1/1/volume.uint32_t.raw';
		system(['cp ' volPath chn_path ' ' full_path '/']);
		system(['cp ' volPath seg_path ' ' full_path '/']);		

		%% Copy channel & segmentation data (mip-level 0)
		%
		mip_level = 0;
		[chn] = load_channel( T, tID, VOL, mip_level );
		[seg] = load_segmentation( T, tID, VOL, mip_level );
		fchn = fopen([full_path '/volume256.float.raw'],'w');
		fseg = fopen([full_path '/volume256.uint32_t.raw'],'w');
		fwrite(fchn,chn,'float');
		fwrite(fseg,seg,'uint32');
		fclose(fchn);
		fclose(fseg);

	end

end