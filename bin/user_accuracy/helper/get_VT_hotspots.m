function [hotspot_IDs,super_users] = get_VT_hotspots( V, T )

hotspot = zeros(1,T.Count);
super_users = [];

%% Validation-wise processing
%
keys	= V.keys;
vals 	= V.values;
for i = 1:V.Count
   
    vID 	= keys{i};
    vInfo 	= vals{i};

    tID     = vInfo.tID;
    tInfo   = T(tID);
    
    % fprintf( '%dth validation (vID=%d) is now processing...\n', i, vID );
    
    if( vInfo.weight > 1 )
        hotspot(i) = tID;
        if( isempty(find(super_users == vInfo.uID)) )
            super_users = [super_users vInfo.uID];
        end
    end
    
end

hotspot_idx = find(hotspot);
hotspot_IDs = hotspot(hotspot_idx);

end