function [triples] = ST_extract_current_segment_triples( data )
%% Argument description
%
%	data:
%		data.S_ui
%		data.V_i
%		data.sigma
%		data.map_i_tID


S = data.S_ui;
IDX = S > -1;

% get (m,n,sigma) subscripts
m = sum(IDX,1);
n = sum(IDX.*S,1);
sigma = data.sigma;

% segment triples
dim = max(m);
triples = zeros(dim,dim+1,2);
linIdx = sub2ind(size(triples),m',(n+1)',(sigma+1)');

TABLE = tabulate(linIdx);
valid_idx = TABLE(:,2) > 0;
idx = TABLE(valid_idx,1);
val = TABLE(valid_idx,2);
triples(idx) = val;

end