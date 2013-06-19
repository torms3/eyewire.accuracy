function [args] = create_arguments( period, t_status, cell_list, user_list )

	%% Period
	%
	if( ~exist('period','var') )
		period.since = '';
		period.until = '';
	end
	args.period = period;


	%% Cell list
	%
	if( ~exist('cell_list','var') )
		cell_list.IDs = [0];
		cell_list.types = ''; 
	end
	args.cell_list = cell_list;


	%% User list
	%
	if( ~exist('user_list','var') )
		user_list.uIDs = [];
		user_list.username = '';
	end
	complete_user_list( user_list );
	args.user_list = user_list;


	%% Task status
	%
	if( ~exist('t_status','var') )
		t_status = [0];
	end
	args.t_status = t_status;

end