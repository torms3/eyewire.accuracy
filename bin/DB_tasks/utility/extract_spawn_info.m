function [] = extract_spawn_info( DB_MAPs )

V = DB_MAPs.V;
T = DB_MAPs.T;

tIDs = cell2mat(T.keys);
tVal = cell2mat(T.values);

vIDs = cell2mat(V.keys);
vVal = cell2mat(V.values);

created = extractfield(tVal,'datenum');
assert(issorted(created));
finished = extractfield(vVal,'datenum');
% The below assertion is not always true due to the GrimReaper activity
% assert(issorted(finished));
weight = extractfield(vVal,'weight');


%% Cube-wise processing
%
for i = 1:T.Count

	tID = tIDs(i);
	tInfo = tVal(i);

	% tInfo.spawn = [];
	if( isempty(tInfo.children) )
		continue;
	end

	idx = ismember(vIDs,tInfo.vIDs);
	assert(nnz(idx) == numel(tInfo.vIDs));
	f = finished(idx);
	w = weight(idx);	

	valid_idx = w > 0;
	f = f(valid_idx);
	w = w(valid_idx);

	% GrimReaper validation filter
	GR = w > CONST.GrimReaper_thresh;

	if( nnz(GR) == 0 | nnz(GR) == 1 )
			
	else
		disp(tID);
		disp(nnz(GR));
	end
	assert( nnz(GR) == 0 | nnz(GR) == 1 );

	% Supposedely GrimReaper cube
	if( tInfo.weight ~= numel(w) )
		assert( tInfo.weight > CONST.GrimReaper_thresh );
		% fprintf('tID = %d\n',tID);
		% fprintf('weight = %d\n',tInfo.weight);
		% fprintf('nv = %d\n',numel(w));
	end

	ch = tInfo.children;
	% tInfo.spawn = zeros(1,numel(ch));
	for j = 1:numel(ch)

		chInfo = T(ch(j));
		c = chInfo.datenum;
		chInfo.spawn = nnz(f < c);

		% spawned by GrimReaper activity?
		if( nnz(GR) > 0 )
			[~,srt_idx] = sort(f,'ascend');
			if( srt_idx(GR) == chInfo.spawn )
				chInfo.spawn = -chInfo.spawn;
			end
		end

		% update
		T(ch(j)) = chInfo;

	end

end

end