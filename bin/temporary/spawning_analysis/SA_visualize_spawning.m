function [F] = SA_visualize_spawning( DB_MAPs )

	%% Options
	%
	frontier_mode = false;
	GrimReaper_cube = false;
	interactive_mode = true;
	movie_recording = false;


	%% Argument validations
	%
	T 	= DB_MAPs.T;
	V 	= DB_MAPs.V;
	VOL = DB_MAPs.VOL;

	created = extractfield( cell2mat(T.values), 'datenum' );
	assert( issorted(created) );
	

	%% Pre-compute weight distribution
	%
	[w,vw,hotspot] = SA_compute_weight_distribution( DB_MAPs );
	% vw(vw==0) = 1;
	maxw = max(vw);
	color = colormap(jet(maxw+1));


	%% For representing GrimReaper cubes
	%
	X = zeros(T.Count,1);
	Y = zeros(T.Count,1);
	Z = zeros(T.Count,1);


	%%
	%
	global cubePool argVisible argOff argOn
	cubePool = cell(T.Count,1);
	argVisible = repmat({'visible'},6,1);
	argOff = repmat({'off'},6,1);
	argOn = repmat({'on'},6,1);


	%%
	%
	% if( movie_recording )
	% 	F(T.Count) = struct('cdata',[],'colormap',[]);
	% end


	%% Cube-wise processing
	%
	global keys vals
	keys	= T.keys;
	vals 	= T.values;
	for i = 1:T.Count

		% cube info
		tID = keys{i};
		tInfo = vals{i};
		fprintf('(%d/%d) %d-th cube is now being processed...\n',i,T.Count,i);

		% volume info`
		chID = tInfo.chID;
		volInfo = VOL(chID);

		X(i) = volInfo.vx;
		Y(i) = volInfo.vy;
		Z(i) = volInfo.vz;

		% plot a cube
		alpha = 1.0;
		data = [X(i) Y(i) Z(i)];
		szCube = 0.9*[1 1 1];
		if( frontier_mode )
			if( w(i) < 3 )
				cubePool{i} = plotcube( szCube, data, alpha, [1 1 0] );
			else
				cubePool{i} = plotcube( szCube, data, alpha, [.5 .5 .5] );
			end
		else
			cubePool{i} = plotcube( szCube, data, alpha, color(vw(i)+1,:) );
		end
		
		cellfun(@set,cubePool{i},argVisible,argOff);
		
	end


	%% GrimReaper cubes
	%
	if( GrimReaper_cube )
		X(~hotspot) = [];
		Y(~hotspot) = [];
		Z(~hotspot) = [];
		scatter3sph( X+.5,Y+.5,Z+.5, 'size', 1.25 );
	end


	axis equal;
	h = gcf;

	%% Set KeyPressFcn
	%	
	if( interactive_mode )
		global cubeIdx
		cubeIdx = 1;		
		set( h, 'KeyPressFcn', @(obj,evt) moveZ( evt.Key, T.Count ) );
	end


	%% Movie recording
	%
	if( movie_recording )
		% set( gca, 'NextPlot', 'replaceChildren' );
		F(T.Count) = struct('cdata',[],'colormap',[]);
		for i = 1:T.Count

			cellfun(@set,cubePool{i},argVisible,argOn);			
			F(i) = getframe(gcf);

		end
	else
		F = [];
	end

end


function moveZ( key, nCube )

	global keys vals
	global cubePool argVisible argOff argOn
	global cubeIdx

	switch key
	case 'rightarrow'
		cubeIdx = cubeIdx + 1;
		if( cubeIdx > nCube )
			cubeIdx = nCube;
		end
		cellfun(@set,cubePool{cubeIdx},argVisible,argOn);
	case 'leftarrow'
		cellfun(@set,cubePool{cubeIdx},argVisible,argOff);
		cubeIdx = cubeIdx - 1;
		if( cubeIdx < 1 )
			cubeIdx = 1;
		end
	end

	tID = keys{cubeIdx};
	tInfo = vals{cubeIdx};
	disp(sprintf('(%d/%d) tID = %d, w = %d',cubeIdx,nCube,tID,tInfo.weight));

end