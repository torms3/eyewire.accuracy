function [] = extract_spawn_info( DB_MAPs )

V = DB_MAPs.V;
T = DB_MAPs.T;

tIDs = cell2mat(T.keys);
tVal = cell2mat(T.values);

vIDs = cell2mat(V.keys);
vVal = cell2mat(V.values);

created 	= extractfield(tVal,'datenum');
% assert(issorted(created));
finished 	= extractfield(vVal,'datenum');
% assert(issorted(finished));
weight 		= extractfield(vVal,'weight');


%% Cube-wise processing
%
for i = 1:T.Count

	tID = tIDs(i);
	tInfo = tVal(i);

	tInfo.spawn = [];
	if( isempty(tInfo.children) )
		continue;
	end

	idx = ismember(vIDs,tInfo.vIDs);
	f = finished(idx);
	w = weight(idx);

	valid_idx = w > 0;
	f = f(valid_idx);
	w = w(valid_idx);

	% 
	if( tInfo.weight ~= numel(w) )
		assert( tInfo.weight > CONST.GrimReaper_thresh );
		% fprintf('tID = %d\n',tID);
		% fprintf('weight = %d\n',tInfo.weight);
		% fprintf('nv = %d\n',numel(w));
	end

	ch = tInfo.children;
	tInfo.spawn = zeros(1,numel(ch));
	for j = 1:numel(ch)

		chInfo = T(ch(j));
		c = chInfo.datenum;
		tInfo.spawn(j) = nnz(f < c);

	end
	
	% update
	T(tID) = tInfo;

end

end