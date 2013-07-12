function [] = extract_parent_info( T )

	%% Cube-wise processing
	%
	keys	= T.keys;
	for i = 1:T.Count

		tID = keys{i};
		tInfo = T(tID);

		for j = 1:numel(tInfo.children)

			ch = tInfo.children(j);
			chInfo = T(ch);
			chInfo.parent = tID;
			T(ch) = chInfo;

		end

	end

end