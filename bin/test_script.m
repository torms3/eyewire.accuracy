
T = DB_MAPs.T;

sp = zeros(T.Count,2);
idx = 1;

keys 	= T.keys;
for i = 1:T.Count

	tID = keys{i};
	tInfo = T(tID);

	if( isempty(tInfo.children) )
		assert(isempty(tInfo.spawn));
		continue;
	else
		assert(numel(tInfo.children)==numel(tInfo.spawn));
	end
	
	for j = 1:numel(tInfo.children)

		sp(idx,1) = tInfo.children(j);
		sp(idx,2) = tInfo.spawn(j);

		idx = idx + 1;

	end

end