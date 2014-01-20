function [err] = NCM_test_script( data )

	nData = numel(data);
	nError = 4;
	err = zeros(nData,nError);
	for i = 1:nData

		% extract cell ID from the fileName string
		cellID = sscanf(data{i}.fileName,'DB_MAPs__cell_%d_to_2013-11-28.mat');

		err(i,1) = data{i}.ERR_ref.CE;
		err(i,2) = data{i}.ERR_exp.CE;
		err(i,3) = data{i}.NCM_err_45.CE;
		err(i,4) = data{i}.NCM_err.CE;

	end

	% ERR_mean = mean(err);
	% ERR_std = std(err);

	% % plot
	% figure;
	% hold on;
	% bar(ERR_mean);
	% errorbar(ERR_mean,ERR_std,'.k');
	% hold off;

end