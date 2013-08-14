function [STAT] = extract_accuracy( period )

	%% Options
	%	
	t_status = [0];


	%% Global
	%
	update = true;
	[STAT,~] = process_user_stat( update, period, t_status );

end