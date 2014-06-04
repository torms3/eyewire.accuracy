function [] = report_cube_proportion( STAT )

	nv = extractfield(cell2mat(STAT.values),'nv');
	w = extractfield(cell2mat(STAT.values),'weight');

	enf_idx = w > 0.5;
	enf_nv = sum(nv(enf_idx));
	dis_nv = sum(nv(~enf_idx));
	tot_nv = sum(nv);

	fprintf('%d out of %d cubes (%.2f %%) are done by the enfranchised.\n',enf_nv,tot_nv,enf_nv*100/tot_nv);
	fprintf('%d out of %d cubes (%.2f %%) are done by the disenfranchised.\n',dis_nv,tot_nv,dis_nv*100/tot_nv);

end