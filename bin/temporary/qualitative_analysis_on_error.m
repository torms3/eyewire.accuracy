function [triples] = qualitative_analysis_on_error( data, params )

S 	= data.S_ui;
v 	= data.V_i;
IDX = (S > -1);
sigma = data.sigma;
n_items = numel(sigma);

n = sum(S > 0.5,1);
m = sum(S > -0.5,1);

W 		= params.w*ones(1,n_items);
THETA 	= params.theta*ones(1,n_items);

% SUM = sum(IDX.*(W.*S - THETA));			% default model
SUM = sum(IDX.*(W.*(S - THETA)),1);		% nonnegativity model
prediction = 1.0./(1.0 + exp(-SUM));

err 	= data.sigma - prediction;
cl_err 	= data.sigma - double(prediction > 0.5);	% classification error

fn_idx = (cl_err > 0.5);
fp_idx = (cl_err < -0.5);

fn_n = n(fn_idx);
fn_m = m(fn_idx);
fn_v = v(fn_idx);

fp_n = n(fp_idx);
fp_m = m(fp_idx);
fp_v = v(fp_idx);

% error segment triples
dim = max(m);
triples = zeros(dim,dim+1,2);
fp_linIdx = sub2ind(size(triples),fp_m',(fp_n+1)',ones(nnz(fp_idx),1));
fn_linIdx = sub2ind(size(triples),fn_m',(fn_n+1)',2*ones(nnz(fn_idx),1));

for i = 1:numel(fp_linIdx)

	idx = fp_linIdx(i);
	triples(idx) = triples(idx) + fp_v(i);

end
for i = 1:numel(fn_linIdx)

	idx = fn_linIdx(i);
	triples(idx) = triples(idx) + fn_v(i);

end

% normalize cumulative error volume of each (m,n,sigma) with the number of segments
TABLE = tabulate(fp_linIdx);
valid_idx = TABLE(:,2) > 0;
idx = TABLE(valid_idx,1);
val = TABLE(valid_idx,2);
triples(idx) = triples(idx)./val;

TABLE = tabulate(fn_linIdx);
valid_idx = TABLE(:,2) > 0;
idx = TABLE(valid_idx,1);
val = TABLE(valid_idx,2);
triples(idx) = triples(idx)./val;

end