function [data] = CM_prepare_data( USM_data, super_uIDs )

%% Super users for cell 10
%
% jinseop		19
% hsseung		22
% rprentki		23
% GrimReaper	19401


%% Super-user index
%
[~,super_idx,~] = intersect(USM_data.map_u_uID,super_uIDs);


%% Remove super-users
%
[data] = remove_users_from_data( USM_data, super_idx );

end