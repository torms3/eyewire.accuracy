function [UCM] = visualize_user_cube_matrix( DB_MAPs, cellIDs )

	%% Options
	%
	random_shuffle = false;


	U = DB_MAPs.U;
	T = DB_MAPs.T;
	V = DB_MAPs.V;
	[hotspot_IDs,super_users] = get_VT_hotspots( V, T );

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
	cellIDs_str = regexprep(num2str(unique(cellIDs)),' +',' f');
	titleStr = sprintf('visualization for user-cube matrix, cell %s',cellIDs_str);
	title(titleStr);


	%% Mask
	%
	% [06/13/2013 kisuklee]
	% TODO: make these constants modular somewhere else
	ACTIVE = 0;
	STASHED = 6;
	FROZEN = 10;

	stashed_color = [0 154 222];
	% frozen_color = [237 26 61];
	frozen_color = [228 229 66];
	% hotspot_color = [255 0 0];
	hotspot_color = frozen_color;

	mask = zeros([size(UCM) 3]);

	% mask for stashed cubes
	status = extractfield( cell2mat(T.values), 'status' );
	
	idx = (status == STASHED);
	mask(:,idx,1) = stashed_color(1);
	mask(:,idx,2) = stashed_color(2);
	mask(:,idx,3) = stashed_color(3);

	idx = (status == FROZEN);
	mask(:,idx,1) = frozen_color(1);
	mask(:,idx,2) = frozen_color(2);
	mask(:,idx,3) = frozen_color(3);

	hold on;
	imagesc(mask/255.0,'AlphaData',0.3);
	hold off;


	%%
	%
	figure();
	if( random_shuffle )
		subplot(1,2,1);
	end
	idx = (status == ACTIVE);
	imagesc(UCM(:,idx));
	colormap(hot);
	xlabel('cube index');
	ylabel('user index');
	cellIDs_str = regexprep(num2str(unique(cellIDs)),' +',' f');
	titleStr = sprintf('visualization for user-cube matrix, cell %s',cellIDs_str);
	title(titleStr);


	%% Mask
	%
	mask = zeros([size(UCM(:,idx)) 3]);
	hotspot_idx = ismember(tIDs,hotspot_IDs);
	disp(nnz(hotspot_idx));
	hotspot_idx = hotspot_idx(idx);
	disp(nnz(hotspot_idx));
	mask(:,hotspot_idx,1) = hotspot_color(1);
	mask(:,hotspot_idx,2) = hotspot_color(2);
	mask(:,hotspot_idx,3) = hotspot_color(3);

	hold on;
	imagesc(mask/255.0,'AlphaData',0.3);
	hold off;


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