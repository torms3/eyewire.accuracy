function [seg] = load_segmentation( T, tID, VOL, mip_level )

	if ~exist('mip_level','var')
		mip_level = 0;
	else
		mip_level = double(logical(mip_level));
	end

	% channel ID
	tInfo = T(tID);
	chID = tInfo.chID;

	% volume information
	volInfo = VOL(chID);
	volPath = volInfo.path;

	%% Load channel data
	%	
	seg_file = 'volume.uint32_t.raw';
	seg_path = [volPath '/segmentations/segmentation1/' num2str(mip_level) '/' seg_file];
	f = fopen(seg_path,'r');
	
	if( mip_level == 1 )
		seg_dim = [128 128 128];
		seg = zeros(seg_dim);
		raw = fread(f,prod(seg_dim),'uint32');
		seg = reshape(raw,seg_dim);
	else
		seg_dim = [256 256 256];
		scaffold = cell([2 2 2]);
		raw = fread(f,prod(seg_dim),'uint32');
		for i = 1:8
			base = 128^3*(i-1);
			[I,J,K] = ind2sub([2 2 2],i);
			scaffold{I,J,K} = reshape(raw(base+1:base+128^3,:),[128 128 128]);
		end
		seg = cell2mat(scaffold);
	end		

end