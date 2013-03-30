function [map_u_uID] = USM_get_map_user_idx_to_uID( U )

	map_u_uID = cell2mat(U.keys)';

end