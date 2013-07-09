function [] = extract_child_info( T )

keys = cell2mat(T.keys);
vals = cell2mat(T.values);
depth = extractfield(vals,'depth');
l_edge = extractfield(vals,'left_edge');
r_edge = extractfield(vals,'right_edge');
created = extractfield(vals,'datenum');

for i = 1:T.Count

	key = keys(i);
	tInfo = vals(i);

	% depth condition for direct children
	d = tInfo.depth;
	d_idx = (depth == (d+1));

	% left_edge condition for direct children
	l = tInfo.left_edge;
	l_idx = (l_edge > l);

	% right_edge condition for direct children
	r = tInfo.right_edge;
	r_idx = (r_edge < r);

	% get direct children
	child_idx = d_idx & l_idx & r_idx;
	if( nnz(child_idx) == 0 )
		continue;
	end
	children = keys(child_idx);
	birth = created(child_idx);
	[~,birth_idx] = sort(birth,'ascend');
	tInfo.children = children(birth_idx);

	% update
	T(key) = tInfo;

end

end