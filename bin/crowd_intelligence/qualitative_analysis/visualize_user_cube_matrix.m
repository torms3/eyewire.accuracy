function [UCM] = visualize_user_cube_matrix( DB_MAPs, cellID )

	%% Options
	%
	random_shuffle = false;


	U = DB_MAPs.U;
	T = DB_MAPs.T;
	V = DB_MAPs.V;

	nUser = U.Count;
	nCube = T.Count;
	
	UCM = zeros(nUser,nCube);

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
		vInfo = cell2mat(values( V, num2cell(uInfo.vIDs) ));
		cubes = extractfield( vInfo, 'tID' );
		weights = extractfield( vInfo, 'weight' );
		% UCM(i,ismember(tIDs,cubes)) = 1;

		UCM(i,ismember(tIDs,cubes(logical(weights)))) = 2;
		UCM(i,ismember(tIDs,cubes(logical(~weights)))) = 1;

	end


	%% Visualize
	%
	figure();
	if( random_shuffle )
		subplot(1,2,1);
	end
	imagesc(UCM);
	% colormap(gray);
	colormap(hot);
	xlabel('cube index');
	ylabel('user index');
	titleStr = sprintf('visualization for user-cube matrix, cell %d',cellID);
	title(titleStr);


	%% Random shuffling of the cubes
	%
	if( random_shuffle )
		randIdx = randperm(numel(tIDs));
		UCM = UCM(:,randIdx);

		subplot(1,2,2);
		imagesc(UCM);
		xlabel('shuffled cube index');
		ylabel('user index');
		title('after randomly shuffling cubes');
	end

end