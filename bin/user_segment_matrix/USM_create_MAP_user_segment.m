function [MAP_user_seg] = USM_create_MAP_user_segment( U, V, T, VOL )

%% User-wise processing
%
idx = 0;
uIDs 	= U.keys;
for i = 1:U.Count 

	uID = uIDs{i};

	% fprintf( '%dth user (u_id=%d) is now processing...\n', i, uID );
    
	uInfo = U(uID);
	val = extract_user_row( uInfo, V, T, VOL );
	if( ~isempty(val) )
		idx = idx + 1;
		vals{idx} = val;
		keys{idx} = [uID];
	end

end

MAP_user_seg = containers.Map( keys, vals );

end


function [MAP_user_row] = extract_user_row( uInfo, V, T, VOL )

%% Option
%
include_seed = false;


%% Iterate through validations of each user
%
idx = 0;
vIDs = uInfo.vIDs;
for i = 1:numel(vIDs)

	% votes for this cube
	vID 	= vIDs(i);
	vInfo 	= V(vID);
	% discard validations with weight = 0
	if( vInfo.weight == 0 )
		continue;
	else
		idx = idx + 1;
	end
	% idx = idx + 1;	% TEMP

	seg 	= vInfo.segs;

	% total segments for this cube
	tID 	= vInfo.tID;
	tInfo 	= T(tID);
	chID	= tInfo.chID;
	n_seg 	= VOL(chID).n_seg;

	% data element
	vals{idx}.tInfo	= tInfo;	% info. from MAP_t_info
	vals{idx}.n_seg = n_seg;	% info. from MAP_vol_info
	if( include_seed )
		vals{idx}.seg = union(seg,tInfo.seed);
	else
		vals{idx}.seg = seg;
	end	

	% keys
	keys{idx} = [tID];

end

if( idx == 0 )
	MAP_user_row = [];
else
	MAP_user_row = containers.Map( keys, vals );
end

end