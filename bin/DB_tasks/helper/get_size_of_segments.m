function [size_of_seg,n_seg] = get_size_of_segments( volInfo, seg )

size_of_seg = [];
n_seg = 0;
if( isempty(seg) )
	return;
end
size_of_seg = zeros(1,numel(seg));

vol_path = volInfo.path;
seg_path = '/users/_default/segmentations/segmentation1/segments/';
page_size = 100000;
page_num = floor(max(seg)/page_size);
% if( page_num > 0 )
% 	disp(page_num);
% 	page_num = 0;
% end
page_num = 0;

seg_file = sprintf('segment_page%d.data.ver4',page_num);
full_path = [vol_path seg_path seg_file];
try
	[segID,segSize] = read_segment_size( full_path );

	idx = segID > 0;
	segID = segID(idx);
	segSize = segSize(idx);
	% assert( isequal(size(segID),size(segSize)) );

	% [size_of_seg] = segSize(seg);
	idx = ismember(segID,seg);
	[~,IA,IB] = intersect(segID,seg);
	size_of_seg(IB) = segSize(IA);
	[n_seg] = numel(segID);
catch err
	disp(['Error in read_segment_size()']);
	size_of_seg = [];
	n_seg = 0;
end

end