function ST_extract_segment_triples( save_path, DB_MAPs )

%% Cube-wise processing
%
T = DB_MAPs.T;
V = DB_MAPs.V;
VOL = DB_MAPs.VOL;

keys 	= T.keys;
vals 	= T.values;
for i = 1:T.Count

	tID = keys{i};
	tInfo = vals{i};
	fprintf('%dth cube (tID=%d) is now processing...\n',i,tID);

	chID = tInfo.chID;
	volInfo = VOL(chID);
	n_seg = volInfo.n_seg;

	% union, consensus, and seed for this cube
	c_seg = tInfo.consensus;
	u_seg = tInfo.union;
	s_seg = tInfo.seed;

	% number of true negative segments for this cube
	tn = n_seg - numel(u_seg);

	% do not consider the seed segments
	c_seg = setdiff(c_seg,s_seg);
	u_seg = setdiff(u_seg,s_seg);

	% array for tracing (m,n)
	votes = zeros(1,numel(u_seg));
	sub = zeros(numel(votes),3);

	% sigma
	c_idx = ismember(u_seg,c_seg);
	sigma = zeros(1,numel(u_seg));
	sigma(c_idx) = 1;

	% whether or not super-users has intervened this cube
	hotspot = 0;	% ?

	% triples
	vIDs = tInfo.vIDs;
	nv = numel(vIDs);
	assert( nv > 0 );
	triples = zeros(nv,nv+1,2);

	% for each segment
	m = 0;
	for j = 1:nv

		vID = vIDs(j);
		vInfo = V(vID);
		seg = vInfo.segs;

		% super-user specific processing should be here

		% % update votes
		m = m + 1;
		idx = ismember(u_seg,seg);
		votes(idx) = votes(idx) + 1;

		% extract segment triples (m,n,sigma)
		for k = 1:numel(votes)

			n = votes(k);
			sig = sigma(k);

			triples(m,n+1,sig+1) = triples(m,n+1,sig+1) + 1;

		end

		% batch processing of true negative segments
		triples(m,0+1,0+1) = triples(m,0+1,0+1) + tn;

	end

	file_name = sprintf('tID_%d.dat',tID);
	dlmwrite([save_path file_name],triples);

end

end