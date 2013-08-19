function [output] = weekly_promotion_demotion_script( period )
	%% Weekly promotion/demotion automation script version 1.0
	%	08/19/2013 kisuklee
	%	kisuklee@mit.edu

	args.period = period;
	args.t_status = [0];
	updateDB = false;
	[output] = promotion_demotion( args, updateDB );

end
