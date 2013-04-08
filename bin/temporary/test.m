
triples = zeros(max(m),max(m)+1,2);
for i = 1:numel(m)

	triples(m(i),n(i),data.sigma(i)+1) = triples(m(i),n(i),data.sigma(i)+1) + 1;

end

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

% nv = zeros(1,T.Count);
% w  = zeros(1,T.Count);
% c  = zeros(1,T.Count);

% keys 	= T.keys;
% vals 	= T.values;
% for i = 1:T.Count

% 	tInfo = vals{i};

% 	nv(i) = numel(tInfo.vIDs);
% 	w(i)  = tInfo.weight;
% 	c(i)  = tInfo.datenum;

% end