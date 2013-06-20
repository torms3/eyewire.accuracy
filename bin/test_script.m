
U = DB_MAPs.U;
T = DB_MAPs.T;
V = DB_MAPs.V;

%% Validation-wise processing
%
vIDs = cell2mat(V.keys);
for i = 1:numel(vIDs)

	vID = vIDs(i);
	vInfo = V(vID);

	vSeg = vInfo.segs;
	uSeg = T(vInfo.tID).union;

	assert( nnz(ismember(uSeg,vSeg)) == numel(vSeg) );

end