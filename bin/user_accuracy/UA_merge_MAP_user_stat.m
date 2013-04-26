function [U3] = UA_merge_MAP_user_stat( U1, U2 )

U3 = containers.Map( U1.keys, U1.values );

keys1 = cell2mat(U1.keys);
keys2 = cell2mat(U2.keys);
update_keys = intersect( keys1, keys2 );
for i = 1:numel(update_keys)

	key = update_keys(i);
	assert( strcmp( U1(key).username, U2(key).username ) );
	val.username = U1(key).username;
	assert( U1(key).weight == U2(key).weight );	
	val.weight = U1(key).weight;
	val.nv = U1(key).nv + U2(key).nv;
	val.hot = U1(key).hot + U2(key).hot;

	val.n_seg = U1(key).n_seg + U2(key).n_seg;
	val.tp = U1(key).tp + U2(key).tp;
	val.fn = U1(key).fn + U2(key).fn;
	val.fp = U1(key).fp + U2(key).fp;
	val.tn = U1(key).tn + U2(key).tn;
	
	val.n_voxels = U1(key).n_voxels + U2(key).n_voxels;
	val.tpv = U1(key).tpv + U2(key).tpv;
	val.fnv = U1(key).fnv + U2(key).fnv;
	val.fpv = U1(key).fpv + U2(key).fpv;
	val.tnv = U1(key).tnv + U2(key).tnv;
	
	val.s_prec = val.tp/(val.tp + val.fp);
	val.s_rec = val.tp/(val.tp + val.fn);
	val.s_fs = 2*(val.s_prec*val.s_rec)/(val.s_prec + val.s_rec);
	
	val.v_prec = val.tpv/(val.tpv + val.fpv);
	val.v_rec = val.tpv/(val.tpv + val.fnv);
	val.v_fs = 2*(val.v_prec*val.v_rec)/(val.v_prec + val.v_rec);
	
	val.s_p1 = val.s_rec;
	val.s_p0 = val.tn/(val.tn + val.fp);
	val.s_a = log((val.s_p1.*val.s_p0)./((1 - val.s_p1).*(1 - val.s_p0)));
	val.s_b = log((1 - val.s_p1)./val.s_p0);

	val.v_p1 = val.v_rec;
	val.v_p0 = val.tnv/(val.tnv + val.fpv);
	val.v_a = log((val.v_p1.*val.v_p0)./((1 - val.v_p1).*(1 - val.v_p0)));
	val.v_b = log((1 - val.v_p1)./val.v_p0);	

	U3(key) = val;

end

U3 = [U2;U3];

end