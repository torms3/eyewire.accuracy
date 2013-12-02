function [saveInfo] = get_classifier_save_info( savePath, nUser, setting )
%% Argument description
%
%	savePath
%
%	setting:
%		setting.eta:	learning rate parameter
%		setting.iter:	# of epochs
%		setting.period:	sampling period (epochs)
%		setting.dense:	dense sampling interval (epochs)
%

saveInfo.savePath = savePath;
prefix = sprintf('params__u%d_eta%g_iter%d',nUser,setting.eta,setting.iter);
saveInfo.prefix = prefix;

end