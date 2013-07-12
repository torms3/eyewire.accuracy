function [] = SA_visualize_spawning( DB_MAPs )

	%% Option
	%
	frontier_mode = false;


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
	

	%% Cube-wise processing
	%
	keys	= T.keys;
	for i = 1:T.Count

		% cube info
		tID = keys{i};
		tInfo = T(tID);
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
				plotcube( szCube, data, alpha, [1 1 0] );
			else
				plotcube( szCube, data, alpha, [.5 .5 .5] );
			end
		else
			plotcube( szCube, data, alpha, color(vw(i)+1,:) );
		end

	end


	%% GrimReaper cubes
	%
	X(~hotspot) = [];
	Y(~hotspot) = [];
	Z(~hotspot) = [];
	% scatter3sph( X+.5,Y+.5,Z+.5, 'size', 1.25 );

	axis equal;

end


%% Legacy code
%

% plane images
% img_zy = zeros([szz szy]);
% img_zx = zeros([szz szx]);
% img_xy = zeros([szx szy]);

% plot evolution
% img_zy(img_zy~=0) = img_zy(img_zy~=0) + 0.005;
% img_zy(z,y) = 1;
% imagesc(img_zy);
% axis equal;
% axis off;
% drawnow;

% if( mod(i,10) == 0 )
% 	drawnow;
% end