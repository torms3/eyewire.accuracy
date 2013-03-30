function [MAP_seg_user] = USM_create_MAP_segment_user( T, V, VOL )

%% Cube-wise processing
%
keys 	= T.keys;
for i = 1:T.Count 

	tID = keys{i};	

	fprintf( '%dth cube (t_id=%d) is now processing...\n', i, tID );
    
	tInfo = T(tID);
	vals{i} = extract_cube_row( tInfo, V, VOL );

end

MAP_seg_user = containers.Map( keys, vals );

end


function [cube_row] = extract_cube_row( tInfo, V, VOL )

% total segments for this cube
chID = tInfo.chID;
n_seg = VOL(chID).n_seg;
cube_row.tInfo = tInfo;
cube_row.n_seg = n_seg;

%% Iterate through user validations of a cube
%
uIDs = [];
vIDs = tInfo.vIDs;
for i = 1:numel( vIDs )

	vID 	= vIDs(i);
	vInfo 	= V(vID);
	seg 	= vInfo.segs;
	segs{i} = seg;

	uID 	= vInfo.uID;
	uIDs(i) = uID;
	
end

keys = num2cell(uIDs);
cube_row.MAP_cube_row = containers.Map( keys, segs );

end