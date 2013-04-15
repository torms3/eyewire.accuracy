function [DB_MAPs] = extract_spawn_info( DB_MAPs )

V = DB_MAPs.V;
T = DB_MAPs.T;

tIDs = cell2mat(T.keys);
tVal = cell2mat(T.values);

vIDs = cell2mat(V.keys);
vVal = cell2mat(V.values);

created 	= extractfield(tVal,'datenum');
finished 	= extractfield(vVal,'datenum');
weight 		= extractfield(vVal,'weight');

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

	if( tInfo.weight ~= numel(w) )
		fprintf('tID = %d\n',tID);
		fprintf('weight = %d\n',tInfo.weight);
		fprintf('nv = %d\n',numel(w));
	end

	idx = ismember(tIDs,tInfo.children);
	c = created(idx);
	tInfo.spawn = zeros(1,numel(c));
	for j = 1:numel(c)

		tInfo.spawn(j) = nnz(f < c(j));

	end

	% k = 1;	
	% for j = 1:numel(vIDs)

	% 	vID = vIDs(j);
	% 	vInfo = V(vID);

	% 	if( vInfo.datenum > T(tInfo.children(k)).datenum )
	% 		tInfo.spawn = [tInfo.spawn (j-1)];
	% 		k = k + 1;
	% 		if( k > numel(tInfo.children) )
	% 			break;
	% 		end
	% 	end		

	% end

	% if( k == numel(tInfo.children) )
	% 	tInfo.spawn = [tInfo.spawn numel(vIDs)];
	% end

	% update
	T(tID) = tInfo;

end

end