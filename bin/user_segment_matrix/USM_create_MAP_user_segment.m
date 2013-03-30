function [MAP_user_seg] = USM_create_MAP_user_segment( U, V, T, VOL )

%% User-wise processing
%
keys 	= U.keys;
for i = 1:U.Count 

	uID = keys{i};

	% fprintf( '%dth user (u_id=%d) is now processing...\n', i, uID );
    
	uInfo = U(uID);
	vals{i} = extract_user_row( uInfo, V, T, VOL );

end

MAP_user_seg = containers.Map( keys, vals );

end


function [MAP_user_row] = extract_user_row( uInfo, V, T, VOL )

%% Iterate through validations of each user
%
vIDs = uInfo.vIDs;
for i = 1:numel(vIDs)

	% votes for this cube
	vID 	= vIDs(i);
	vInfo 	= V(vID);
	seg 	= vInfo.segs;

	% total segments for this cube
	tID 	= vInfo.tID;
	tInfo 	= T(tID);
	chID	= tInfo.chID;
	n_seg 	= VOL(chID).n_seg;

	% data element
	vals{i}.tInfo	= tInfo;	% info. from MAP_t_info
	vals{i}.n_seg 	= n_seg;	% info. from MAP_vol_info
	vals{i}.seg 	= seg;		% info. from MAP_v_info

	% keys
	keys{i} = [tID];

end

MAP_user_row = containers.Map( keys, vals );

end