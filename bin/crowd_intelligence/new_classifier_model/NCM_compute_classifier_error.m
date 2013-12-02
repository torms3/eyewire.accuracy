function [NCM_error] = NCM_compute_classifier_error( data, params, cls_th )

if( ~exist('cls_th','var') )
	cls_th = 0.5;
end

%% Compute RMSE and CE
%
M = data.matrix;
[nUser,nItem] = size(M);
v = data.segSize;
IDX = (M ~= 0);
M(M==-1) = 0;

W 		= params.w*ones(1,nItem);
THETA 	= params.theta*ones(1,nItem);

SUM = sum(IDX.*(W.*M - THETA));			% default model
% SUM = sum(IDX.*(W.*(M - THETA)),1);		% nonnegativity model
prediction = 1.0./(1.0 + exp(-SUM));	% logistic nonlinearity

% RMSE
err 	= data.sigma - prediction;
cl_err 	= data.sigma - double(prediction > cls_th);	% classification error

% compute error
[NCM_error] = NCM_compute_error( err, cl_err, data );

end