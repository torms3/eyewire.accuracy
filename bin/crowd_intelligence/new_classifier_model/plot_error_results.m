function [] = plot_error_results( err_def, err_nn )

	err_def_mean = mean(err_def);
	err_nn_mean = mean(err_nn);

	err_def_std = std(err_def);
	err_nn_std = std(err_nn);

	figure;
	hold on;

		barweb([err_def_mean;err_nn_mean],[err_def_std;err_nn_std],...
			0.9,{'Default model';'Constrained model'},...
			[],[],'Classification error (% volume)',[],[],...
			{'Expert','Expert + Novice','Weighted vote with prior','Weighted vote'});

	hold off;	

end