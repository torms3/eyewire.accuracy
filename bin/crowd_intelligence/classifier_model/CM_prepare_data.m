function [data] = CM_prepare_data( USM_data, super_index )

%% Super users for cell 10
%
% jinseop		19
% hsseung		22
% rprentki		23
% GrimReaper	19401


%% Remove super-users
%
[data] = remove_users_from_data( USM_data, super_index );

end