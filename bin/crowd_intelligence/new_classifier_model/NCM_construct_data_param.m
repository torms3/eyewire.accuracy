function [data_param] = NCM_construct_data_param( data, MAP_param )

	[nUser,nItem] = size(data.matrix);
	data_param.w = zeros(nUser,1);
	data_param.theta = zeros(nUser,1);
	data_param.novice = true(nUser,1);
	for i = 1:nUser

		uID = data.uIDs(i);
		if( isKey(MAP_param,uID) )
			val = MAP_param(uID);
			data_param.w(i) = val.w;
			data_param.theta(i) = val.theta;
			data_param.novice(i) = false;
		end

	end
	
end