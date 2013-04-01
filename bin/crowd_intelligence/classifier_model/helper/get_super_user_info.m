function [super_uIDs,super_idx] = get_super_user_info( U, V )
%% Argument description
%
%	U:	MAP_u_info
%	V: 	MAP_v_info
%


%% Super-user uIDs
%
super_uIDs = [];


%% User-wise processing
%
keys	= U.keys;
vals	= U.values;
for i = 1:U.Count

	uID = keys{i};
	% fprintf('%dth user (uID=%d) is now processing...\n',i,uID);

	% iterate through validations of each user
	uInfo = vals{i};
	vIDs = uInfo.vIDs;
	for j = 1:numel(vIDs)

		vID = vIDs(j);
		vInfo = V(vID);
		if( vInfo.weight > 1 )			
			super_uIDs = [super_uIDs uID];
			fprintf('%dth super-user (uID=%d) found...\n',numel(super_uIDs),uID);
			break;
		end

	end

end


%% Super-user index
%
[~,super_idx,~] = intersect(cell2mat(U.keys),super_uIDs);

end