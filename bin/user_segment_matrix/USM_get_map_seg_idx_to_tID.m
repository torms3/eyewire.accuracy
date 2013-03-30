function [map_tIDs] = USM_get_map_seg_idx_to_tID( META )

keys 	= META.keys;
vals 	= META.values;

map_tIDs.s1 = zeros(1,META(0).offset_s1);
map_tIDs.s0 = zeros(1,META(0).offset_s0);

for i = 2:META.Count

	tID = keys{i};

	start_index_s1 	= vals{i}.offset_s1 + 1;
	start_index_s0 	= vals{i}.offset_s0 + 1;
	
	if( i < META.Count )
		end_index_s1	= vals{i+1}.offset_s1;
		end_index_s0	= vals{i+1}.offset_s0;
	else
		end_index_s1	= size(map_tIDs.s1,2);
		end_index_s0	= size(map_tIDs.s0,2);
	end	

	map_tIDs.s1(start_index_s1:end_index_s1) = tID;
	map_tIDs.s0(start_index_s0:end_index_s0) = tID;

end

end