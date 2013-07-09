function [] = SA_visualize_spawning( DB_MAPs )

	%% Argument validations
	%
	T 	= DB_MAPs.T;
	VOL = DB_MAPs.VOL;

	created = extractfield( cell2mat(T.values), 'datenum' );
	assert( issorted(created) );


	%% Image size
	%
	vx = extractfield( cell2mat(VOL.values), 'vx' );
	vy = extractfield( cell2mat(VOL.values), 'vy' );
	vz = extractfield( cell2mat(VOL.values), 'vz' );

	szx = max(vx) - min(vx);
	szy = max(vy) - min(vy);
	szz = max(vz) - min(vz);

	% plane images
	img_zy = zeros([szz szy]);
	img_zx = zeros([szz szx]);
	img_xy = zeros([szx szy]);
	

	%% Pre-processing
	%
	colormap(hot);

	%% Cube-wise processing
	%
	X = zeros(T.Count,1);
	Y = zeros(T.Count,1);
	Z = zeros(T.Count,1);

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

		% plot a cube
		% subplot(1,2,1);
		plotcube( 1.25*[1 1 1], [x y z], 0.3, [.5 .5 .5] );
		% axis equal;
		% drawnow;

		% subplot(1,2,2);
		% img_zy(img_zy~=0) = img_zy(img_zy~=0) + 0.005;
		% img_zy(z,y) = 1;
		% imagesc(img_zy);
		% axis equal;
		% axis off;
		% drawnow;

		% X(i) = x; Y(i) = y; Z(i) = z;
		% scatter(Y(1:i),Z(1:i),120,'s');
		% axis equal;
		% drawnow;

		% if( mod(i,10) == 0 )
		% 	drawnow;
		% end

	end

	axis equal;

end


function plot_image( img, sub, idx )

	for i = 1:numel(idx)

	end
	imagesc(img);
	exis off;
	exis equal;
	drawnow;

end