function [] = NCM_test_script( data )

	nData = numel(data);
	nError = 9;
	err = zeros(nData,nError);
	prec = zeros(nData,nError);
	rec = zeros(nData,nError);
	for i = 1:nData

		% extract cell ID from the fileName string
		cellID = sscanf(data{i}.fileName,'DB_MAPs__cell_%d_to_2013-11-28.mat');

		err(i,1) = data{i}.ERR_ref.CE;
		err(i,2) = data{i}.ERR_exp.CE;
		err(i,3) = data{i}.NCM_err_30.CE;
		err(i,4) = data{i}.NCM_err_35.CE;
		err(i,5) = data{i}.NCM_err_40.CE;
		err(i,6) = data{i}.NCM_err_45.CE;
		err(i,7) = data{i}.NCM_err.CE;
		err(i,8) = data{i}.NCM_err_55.CE;
		err(i,9) = data{i}.NCM_err_60.CE;

	end

	ERR_mean = mean(err);

	% plot
	bar(ERR_mean);

	%
	% bar([mean(err(:,1)) mean(err(:,2)) mean(err(:,3))]);
	% bar([1-mean(prec(:,1)) 1-mean(prec(:,2)) 1-mean(prec(:,3))]);
	% bar([1-mean(rec(:,1)) 1-mean(rec(:,2)) 1-mean(rec(:,3))]);

end