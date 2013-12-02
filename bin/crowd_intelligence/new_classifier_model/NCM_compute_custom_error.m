function [custom_err] = NCM_compute_custom_error( data, params, numExp )

if( ~exist('numExp','var') )
	numExp = 3;
end

%% Compute RMSE and CE
%
M = data.matrix;
[nUser,nItem] = size(M);
IDX = (M ~= 0);

% at least 3 experts
experts = double(~params.novice) * ones(1,nItem);
valid_idx = sum(IDX.*experts,1) >= numExp;
disp([num2str(nnz(valid_idx)) ' valid segs out of ' num2str(nItem)]);

% process data
data.seed = data.seed(valid_idx);
data.sigma = data.sigma(valid_idx);
data.segSize = data.segSize(valid_idx);
data.matrix = data.matrix(:,valid_idx);
M = data.matrix;
[nUser,nItem] = size(M);
v = data.segSize;
IDX = (M ~= 0);
M(M==-1) = 0;

W 		= params.w*ones(1,nItem);
THETA 	= params.theta*ones(1,nItem);

SUM = sum(IDX.*(W.*M - THETA));			% default model
% SUM = sum(IDX.*(W.*(M - THETA)),1);	% nonnegativity model
prediction = 1.0./(1.0 + exp(-SUM));	% logistic nonlinearity

% RMSE
err 	= data.sigma - prediction;
cl_err 	= data.sigma - double(prediction > 0.5);	% classification error

% compute error
[custom_err] = NCM_compute_error( err, cl_err, data );

custom_err.numExp = numExp;

end