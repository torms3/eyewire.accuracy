function [save_info] = get_classifier_save_info( save_path, n_users, setting )
%% Argument description
%
%	save_path
%
%	setting:
%		setting.eta:	learning rate parameter
%		setting.iter:	# of epochs
%		setting.period:	sampling period (epochs)
%		setting.dense:	dense sampling interval (epochs)
%

save_info.save_path = save_path;
prefix = sprintf('params__u_%d_eta_%0.12f_iter_%d',n_users,setting.eta,setting.iter);
save_info.prefix = prefix;

end