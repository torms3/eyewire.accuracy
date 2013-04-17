function [size_of_seg] = get_size_of_segments_old( vol_info, seg )

size_of_seg = [];
if( isempty(seg) )
	return;
end

vol_path = vol_info.path;
seg_path = '/users/_default/segmentations/segmentation1/segments/';
page_size = 100000;
page_num = floor(max(seg)/page_size);
seg_file = sprintf('segment_page%d.data.ver4',page_num);
fp = fopen([vol_path seg_path seg_file],'r');
if( fp < 0 )
	seg_file = 'segment_page0.data.ver4';
	fp = fopen([vol_path seg_path seg_file],'r');
end
seg_data_size = 48;
offset_to_size_info = 8;

% extract the size of segments
n_seg = numel(seg);
size_of_seg = zeros(1,n_seg);
for i = 1:n_seg

	seg_id = seg(i);
	offset = seg_data_size*seg_id;

	% segment ID
	fseek(fp,offset,'bof');
	seg_id_in_file = fread(fp,1,'*uint32');
	% assert( seg_id == seg_id_in_file );
	if( seg_id == seg_id_in_file )
		% segment size
		fseek(fp,offset+offset_to_size_info,'bof');
		seg_size = fread(fp,1,'*uint64');
		size_of_seg(i) = seg_size;
	else
		size_of_seg(i) = 0;
	end

end

fclose(fp);

end