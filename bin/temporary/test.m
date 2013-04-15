
keys 	= T.keys;
vals 	= T.values;
for i = 1:T.Count

	tID = keys{i};
	tInfo = vals{i};

	% idx = (tInfo.spawn == 1) | (tInfo.spawn == 2);
	% if( nnz(idx) > 0 )
	% 	disp(tID);
	% end

	idx = (tInfo.children == 49376);
	if( nnz(idx) > 0 )
		disp(tID);
	end

end

% triples = zeros(max(m),max(m)+1,2);
% for i = 1:numel(m)

% 	triples(m(i),n(i),data.sigma(i)+1) = triples(m(i),n(i),data.sigma(i)+1) + 1;

% end

%%

% T = DB_MAPs.T;
% V = DB_MAPs.V;

% seg_num = 0;

% for i = 1:numel(weird_tIDs)

% 	tID = weird_tIDs(i);
% 	tInfo = T(tID);
% 	vIDs = tInfo.vIDs;
% 	for j = 1:numel(vIDs)

% 		vID = vIDs(j);
% 		vInfo = V(vID);
% 		seg_num = seg_num + numel(vInfo.segs);

% 	end

% end

%%

% T = DB_MAPs.T;
% V = DB_MAPs.V;

% nv = zeros(1,T.Count);
% nv_w1 = zeros(1,T.Count);
% w  = zeros(1,T.Count);
% c  = zeros(1,T.Count);

% keys 	= T.keys;
% vals 	= T.values;
% for i = 1:T.Count

% 	tInfo = vals{i};
% 	vIDs = tInfo.vIDs;
	
% 	nv(i) = numel(vIDs);
% 	w(i)  = tInfo.weight;
% 	c(i)  = tInfo.datenum;

% 	vInfos = values( V, num2cell(vIDs) );
% 	vw = extractfield( cell2mat(vInfos), 'weight' );
% 	vw = min(vw,1);
% 	nv_w1(i) = sum(vw);

% end

% unames = extractfield( cell2mat(STAT.values), 'username' );

% top14 = {'a5hm0r','blackblues','crazyman4865','ketta','bigbiff','lobusparietalis','susi','acida_2','robz90','furball13','nkem','jinbean','reb1618','marika'};

% uIDs = cell2mat(STAT.keys);
% top14_idx = ismember(unames,top14);
% remove( STAT, num2cell(uIDs(~top14_idx)) );