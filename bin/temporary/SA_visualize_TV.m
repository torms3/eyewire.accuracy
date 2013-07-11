function [] = SA_visualize_TV( DB_MAPs )

	%% Argument validations
	%
	T 	= DB_MAPs.T;
	V 	= DB_MAPs.V;
	VOL = DB_MAPs.VOL;


	%% Image size
	%
	vx = extractfield( cell2mat(VOL.values), 'vx' );
	vy = extractfield( cell2mat(VOL.values), 'vy' );
	vz = extractfield( cell2mat(VOL.values), 'vz' );

	lx = max(vx) - min(vx);
	ly = max(vy) - min(vy);
	lz = max(vz) - min(vz);

	img = zeros([ly lz lx]);

	X = zeros(T.Count,1);
	Y = zeros(T.Count,1);
	Z = zeros(T.Count,1);
	

	%% Pre-compute weight distribution
	%
	[w,vw,hotspot] = SA_compute_weight_distribution( DB_MAPs );
	w(w>CONST.GrimReaper_thresh) = 20;
	vw(vw==0) = 1;
	maxw = max(vw);
	color = colormap(hot(maxw));
	

	%% Cube-wise processing
	%
	keys	= T.keys;
	for i = 1:T.Count

		% cube info
		tID = keys{i};
		tInfo = T(tID);
		fprintf('(%d/%d) %d-th cube is now being processed...\n',i,T.Count,i);

		% volume info
		chID = tInfo.chID;
		volInfo = VOL(chID);

		x = volInfo.vx;
		y = volInfo.vy;
		z = volInfo.vz;

		X(i) = x;
		Y(i) = y;
		Z(i) = z;

		% plot a cube
		% w = vw(i);
		% img(y,z,x) = w;

	end

	% slice(img,[],[],1:size(img,3));	

	scatter3sph(X,Y,Z,'color',color(vw,:),'size',w/10);
	axis equal;

end