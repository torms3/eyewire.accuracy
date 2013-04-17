function [seed_idx] = USM_get_seed_idx( META )

seed_idx = zeros(1,META(0).offset_s1);
padding  = zeros(1,META(0).offset_s0);

keys	= META.keys;
vals 	= META.values;
for i = 2:META.Count

	tID = keys{i};

	head_idx = vals{i}.offset_s1 + 1;
	if( i < META.Count )
		tail_idx = vals{i+1}.offset_s1;
	else
		tail_idx = size(seed_idx,2);
	end	

	seed_idx(head_idx:tail_idx) = vals{i}.seed_idx;

end

seed_idx = [seed_idx padding];

end