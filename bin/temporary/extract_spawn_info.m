function [DB_MAPs] = extract_spawn_info( DB_MAPs )

V = DB_MAPs.V;
T = DB_MAPs.T;

tIDs = cell2mat(T.keys);
tVal = cell2mat(T.values);

vIDs = cell2mat(V.keys);
vVal = cell2mat(V.values);
finished = extractfield(vVal,'datenum');

for i = 1:T.Count

	tID = tIDs(i);
	tInfo = tVal(i);

	tInfo.spawn = [];

	if( isempty(tInfo.children) )
		continue;
	end

	vIDs = tInfo.vIDs;
	k = 1;	
	for j = 1:numel(vIDs)

		vID = vIDs(j);
		vInfo = V(vID);

		if( vInfo.datenum > T(tInfo.children(k)).datenum )
			tInfo.spawn = [tInfo.spawn (j-1)];
			k = k + 1;
			if( k > numel(tInfo.children) )
				break;
			end
		end		

	end

	if( k == numel(tInfo.children) )
		tInfo.spawn = [tInfo.spawn numel(vIDs)];
	end

	% update
	T(tID) = tInfo;

end

end