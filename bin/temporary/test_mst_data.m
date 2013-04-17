function [mstEdge] = test_mst_data( volPath )

seg_path = '/users/_default/segmentations/segmentation1/segments/';
mst_file = 'mst.data';
mst_path = [volPath seg_path mst_file];

dir_info = dir(mst_path);
file_size = dir_info.bytes;

fp = fopen(mst_path,'r');
mst_data_size = 32;
N = file_size/mst_data_size;
mstEdge = cell(N,1);
for i = 1:N

	offset = (i-1)*mst_data_size;
	fseek(fp,offset,'bof');

	data32 = fread(fp,[3,1],'*uint32');
	mstEdge{i}.number 	 = data32(1);
	mstEdge{i}.node1ID 	 = data32(2);
	mstEdge{i}.node2ID 	 = data32(3);
	
	mstEdge{i}.threshold = fread(fp,1,'*double');
	
	data8 = fread(fp,[3,1],'*uint8');
	mstEdge{i}.userJoin		= data8(1);
	mstEdge{i}.userSplit	= data8(2);
	mstEdge{i}.wasJoined 	= data8(3);

end

fclose(fp);

end