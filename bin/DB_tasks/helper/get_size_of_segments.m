function [size_of_seg] = get_size_of_segments( volInfo, seg )

size_of_seg = [];
if( isempty(seg) )
	return;
end

vol_path = volInfo.path;
seg_path = '/users/_default/segmentations/segmentation1/segments/';
page_size = 100000;
page_num = floor(max(seg)/page_size);

page_num = 0;
% if( page_num > 0 )
% 	disp(page_num);
% 	page_num = 0;
% end

seg_file = sprintf('segment_page%d.data.ver4',page_num);
full_path = [vol_path seg_path seg_file];
[segID,segSize] = read_segment_size( full_path );

idx = segID > 0;
segID = segID(idx);
segSize = segSize(idx);
% assert( isequal(size(segID),size(segSize)) );

% [size_of_seg] = segSize(seg);
idx = ismember(segID,seg);
[size_of_seg] = segSize(idx);


end