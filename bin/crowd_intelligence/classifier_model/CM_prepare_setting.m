function [setting] = CM_prepare_setting( eta, iter, period, dense )

%% Argument validation
%
if( ~exist('eta','var') )
	eta = 0.01;
end
if( ~exist('iter','var') )
	iter = 100;
end
if( ~exist('period','var') )
	period = 10;
end
if( ~exist('dense','var') )
	dense = 10;
end


%% training setting
%
setting.eta 	= eta;
setting.iter 	= iter;
setting.period 	= period;
setting.dense 	= dense;

end