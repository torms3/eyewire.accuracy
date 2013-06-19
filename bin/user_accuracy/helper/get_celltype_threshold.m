function [thresh] = get_celltype_threshold( weight, celltype )

	switch( celltype )
	case 'sac'
		thresh = min(0.99,1.00*exp(-0.320*weight) + 0.220);
	otherwise
		thresh = min(0.99,1.00*exp(-0.160*weight) + 0.200);
	end

end