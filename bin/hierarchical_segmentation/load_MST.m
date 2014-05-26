function [mstEdges] = load_MST( T, tID, VOL )

	% channel ID
	tInfo = T(tID);
	chID = tInfo.chID;

	% volume information
	volInfo = VOL(chID);
	volPath = volInfo.path;

	%% Read MST data
	%
	seg_path = '/users/_default/segmentations/segmentation1/segments/';
	mst_file = 'mst.data';
	mst_path = [volPath seg_path mst_file];

	mstEdges = read_mst( mst_path );

end