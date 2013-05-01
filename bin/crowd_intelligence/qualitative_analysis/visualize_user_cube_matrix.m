function visualize_user_cube_matrix( DB_MAPs )

	U = DB_MAPs.U;
	T = DB_MAPs.T;
	V = DB_MAPs.V;

	nUser = U.Count;
	nCube = T.Count;
	
	M = zeros(nUser,nCube);

	uIDs = cell2mat(U.keys)';
	tIDs = cell2mat(T.keys);


	%% User-wise processing
	%
	keys 	= U.keys;
	vals 	= U.values;
	for i = 1:U.Count

		uID = keys{i};
		fprintf('(%d/%d) uID = %d is now processing...\n',i,U.Count,uID);

		uInfo = vals{i};
		cubes = extractfield( cell2mat(values( V, num2cell(uInfo.vIDs))), 'tID' );		
		M(i,ismember(tIDs,cubes)) = 1;

	end


	%% Visualize
	%
	figure();
	subplot(1,2,1);
	imagesc(M);
	colormap(gray);


	%% Random shuffling of the cubes
	%
	randIdx = randperm(numel(tIDs));
	M = M(:,randIdx);

	subplot(1,2,2);
	imagesc(M);	


end