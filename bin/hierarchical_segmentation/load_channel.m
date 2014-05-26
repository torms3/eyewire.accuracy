function [chann] = load_channel( T, tID, VOL, mip_level )

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
	chn_file = 'volume.float.raw';
	chn_path = [volPath '/channels/channel1/' num2str(mip_level) '/' chn_file];
	f = fopen(chn_path,'r');
	
	if( mip_level == 1 )
		chn_dim = [128 128 128];
		chann = zeros(chn_dim);
		raw = fread(f,prod(chn_dim),'float');
		chann = reshape(raw,chn_dim);
	else
		chn_dim = [256 256 256];
		scaffold = cell([2 2 2]);
		raw = fread(f,prod(chn_dim),'float');
		for i = 1:8
			base = 128^3*(i-1);
			[I,J,K] = ind2sub([2 2 2],i);
			scaffold{I,J,K} = reshape(raw(base+1:base+128^3,:),[128 128 128]);
		end
		chann = cell2mat(scaffold);
	end		

end