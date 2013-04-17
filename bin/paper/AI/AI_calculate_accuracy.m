function [AI_MAP] = AI_calculate_accuracy( DB_MAPs, threshold )

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
	[cube_stat] = calculate_AI_accuracy( tInfo, mstEdges, segSize, threshold );
	disp(cube_stat);
	vals{i} = cube_stat;

end

AI_MAP = containers.Map( keys, vals );

end


function [cube_stat] = calculate_AI_accuracy( tInfo, mstEdges, segSize, th )

threshold = extractfield( mstEdges, 'threshold' );
g_node1ID = extractfield( mstEdges, 'node1ID' );
g_node2ID = extractfield( mstEdges, 'node2ID' );

cube_stat.threshold = 0;
cube_stat.seg = [];
cube_stat.tpv = 0;
cube_stat.fnv = 0;
cube_stat.fpv = 0;
cube_stat.err = 1.0;
cube_stat.fs  = 0;

idx = (threshold > th);
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

		idx1 = ismember(node1ID,seed);
		idx2 = ismember(node2ID,seed);

		children1 = node1ID(idx2);
		children2 = node2ID(idx1);

		children = union(children1,children2);
		if( isempty(children) )
			break;
		else
			AI_seg = [AI_seg children];
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

cube_stat.threshold = th;
cube_stat.seg = AI_seg;
cube_stat.tpv = tpv;
cube_stat.fnv = fnv;
cube_stat.fpv = fpv;
cube_stat.err = err;
cube_stat.fs  = fs;

% fprintf('threshold = %f, precision = %f\n',i,prec);
% fprintf('threshold = %f, recall = %f\n',i,rec);

end