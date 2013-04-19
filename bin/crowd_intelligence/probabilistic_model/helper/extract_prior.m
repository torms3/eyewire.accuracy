function [prior] = extract_prior( data, prior_type, sub_type )

switch( prior_type )
case 'cube'
	[prior] = extract_cube_prior( data, sub_type );
otherwise
	assert( false );
end

end


function [prior] = extract_cube_prior( data, sub_type )

%% Argument validation
%
switch( sub_type )
case 'supervoxel'
	V = ones(size(data.V_i));
case 'voxel'
	V = data.V_i;
otherwise
	assert( false );
end


%% Data
%
sigma 	= data.sigma;
map_tID = data.map_i_tID;
prior 	= zeros(size(sigma));


%% Cube-wise processing
%
tIDs = unique( map_tID );
for i = 1:numel(tIDs)

	tID = tIDs(i);
	idx = ismember(map_tID,tID);

	sig = sigma(idx);	
	v 	= V(idx);
	
	s1 = sig*v';
	s0 = (~sig)*v';

	prior(idx) = log(s1/s0);

	% [04/18/2013 kisuklee]
	% TODO:
	% 	INF, NaN manipulation	

end

end