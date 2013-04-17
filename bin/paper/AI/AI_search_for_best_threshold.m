function [AI_MAP] = AI_search_for_best_threshold( DB_MAPs )

T = DB_MAPs.T;
VOL = DB_MAPs.VOL;

%% Cube-wise processing
%
keys 	= T.keys;
tInfos 	= T.values;
for i = 1:T.Count

	tID = keys{i};
	fprintf('(%d/%d) tID = %d is now processing...\n',i,T.Count,tID);
	tInfo = tInfos{i};
	chID = tInfo.chID;

	volInfo = VOL(chID);
	volPath = volInfo.path;


	%% Read MST data
	%
	seg_path = '/users/_default/segmentations/segmentation1/segments/';
	mst_file = 'mst.data';
	mst_path = [volPath seg_path mst_file];

	mstEdges = read_mst( mst_path );


	%% Read segment size data
	%
	page_num = 0;	% SHOULD BE VERIFIED
	meta_file = sprintf('segment_page%d.data.ver4',page_num);
	meta_path = [volPath seg_path meta_file];

	[segID,segSize] = read_segment_size( meta_path );

	idx = segID > 0;
	segID = segID(idx);
	segSize = segSize(idx);


	%% Desired output per each cube
	%
	%	tID
	%	best threshold
	%	AI segments obtained from the best threshold
	%	tpv
	%	fnv
	%	fpv
	%	prec
	%	rec
	%	fs
	%
	[best_stat] = search_for_best_threshold( tInfo, mstEdges, segSize );
	disp(best_stat);
	vals{i} = best_stat;

end

AI_MAP = containers.Map( keys, vals );

end


function [best_stat] = search_for_best_threshold( tInfo, mstEdges, segSize )

threshold = extractfield( mstEdges, 'threshold' );
g_node1ID = extractfield( mstEdges, 'node1ID' );
g_node2ID = extractfield( mstEdges, 'node2ID' );

best_stat.threshold = 0;
best_stat.seg = [];
best_stat.tpv = 0;
best_stat.fnv = 0;
best_stat.fpv = 0;
best_stat.err = 1.0;
best_stat.fs  = 0;

th = fliplr(0.01:0.01:0.99);
for i = th
	
	idx = (threshold > i);
	leftEdges = mstEdges(idx);
	node1ID = g_node1ID(idx);
	node2ID = g_node2ID(idx);

	seed = tInfo.seed;
	AI_seg = [];	

	if( ~isempty(leftEdges) )		
		iter = 0;
		while( true )

			iter = iter + 1;
			% fprintf('%dth iteration.\n',iter);

			% node1ID = extractfield( leftEdges, 'node1ID' );
			% node2ID = extractfield( leftEdges, 'node2ID' );			

			idx1 = ismember(node1ID,seed);
			idx2 = ismember(node2ID,seed);

			children1 = node1ID(idx2);
			children2 = node2ID(idx1);

			children = union(children1,children2);
			if( isempty(children) )
				break;
			else
				AI_seg = [AI_seg children];
				% leftEdges = leftEdges(~(idx1 | idx2));
				seed = children;
				idx = ~(idx1 | idx2);
				node1ID = node1ID(idx);
				node2ID = node2ID(idx);	
			end

		end
	end

	AI_seg = union(AI_seg,tInfo.seed);
	c_seg = union(tInfo.consensus,tInfo.seed);

	tp = intersect(c_seg,AI_seg);
	fn = setdiff(c_seg,AI_seg);
	fp = setdiff(AI_seg,c_seg);

	tpv = sum(segSize(tp));
	fnv = sum(segSize(fn));
	fpv = sum(segSize(fp));

	prec = tpv/(tpv + fpv);
	rec = tpv/(tpv + fnv);
	fs = 2*(prec*rec)/(prec + rec);

	err = (fnv + fpv)/(fnv + fpv + tpv);

	if( best_stat.fs < fs )
		best_stat.threshold = i;
		best_stat.seg = AI_seg;
		best_stat.tpv = tpv;
		best_stat.fnv = fnv;
		best_stat.fpv = fpv;
		best_stat.err = err;
		best_stat.fs  = fs;
	end
	% if( best_stat.err > err )
	% 	best_stat.threshold = i;
	% 	best_stat.seg = AI_seg;
	% 	best_stat.tpv = tpv;
	% 	best_stat.fnv = fnv;
	% 	best_stat.fpv = fpv;
	% 	best_stat.err = err;
	% end

	if( best_stat.fs == 1.0 )
		return;
	end
	% if( best_stat.err == 0.0 )
	% 	return;
	% end

	% fprintf('threshold = %f, precision = %f\n',i,prec);
	% fprintf('threshold = %f, recall = %f\n',i,rec);

end

end