function [hotspot_IDs,super_users] = get_VT_hotspots( V, T )

hotspot_IDs = [];
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
        hotspot_IDs = union(hotspot_IDs,tID);
        super_users = union(super_users,vInfo.uID);        
    end
    
end

end