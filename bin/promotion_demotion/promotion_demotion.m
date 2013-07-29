function [output] = promotion_demotion( args, updateDB )

	%% Argument validation
	%
	if( ~exist('updateDB','var') )
		updateDB = false;
	end


	%% Arguments
	%
	period = args.period;
	t_status = args.t_status;


	%% Global
	%
	update = true;
	[STAT,STAT_per_cell] = process_user_stat( update, period, t_status );
	

	%% SAC
	%
	segInfo = true;
	cellIDs = [-34 -35 -37 -40 -43 -48 -50];	% filter out mystery cells
	[SAC_DB_MAPs] = SAC_construct_DB_MAPs( segInfo, cellIDs, period, [0] );

	seed = false;
	[SAC_UA] = UA_process_user_accuracy( SAC_DB_MAPs, seed );
	[SAC_uSTAT] = UA_create_MAP_uSTAT( SAC_UA, SAC_DB_MAPs );
	

	%% Promotion/demotion info
	%
	[global_uIDs_info] = UA_plot_user_precision_recall_curve( STAT );
	[SAC_uIDs_info] = UA_plot_user_precision_recall_curve( SAC_uSTAT, 'sac' );
	uIDs_info.global = global_uIDs_info;
	uIDs_info.SAC = SAC_uIDs_info;


	%% User list
	%
	global_list.enf_uIDs = global_uIDs_info.enfIDs';
	global_list.enf_uNames = extractfield( cell2mat(values( STAT, num2cell(global_uIDs_info.enfIDs) )), 'username' )';

	global_list.disenf_uIDs = global_uIDs_info.disenfIDs';
	global_list.disenf_uNames = extractfield( cell2mat(values( STAT, num2cell(global_uIDs_info.disenfIDs) )), 'username' )';

	SAC_list.enf_uIDs = SAC_uIDs_info.enfIDs';
	SAC_list.enf_uNames = extractfield( cell2mat(values( STAT, num2cell(SAC_uIDs_info.enfIDs) )), 'username' )';

	SAC_list.disenf_uIDs = SAC_uIDs_info.disenfIDs';
	SAC_list.disenf_uNames = extractfield( cell2mat(values( STAT, num2cell(SAC_uIDs_info.disenfIDs) )), 'username' )';


	%% Actual DB update
	%
	if( updateDB )		
		DB_update_user_weight( global_uIDs_info.enfIDs, 1 );
		DB_update_user_weight( global_uIDs_info.disenfIDs, 0 );
		DB_update_cell_type_user_weight( 'sac', SAC_uIDs_info.enfIDs, 1 );
		DB_update_cell_type_user_weight( 'sac', SAC_uIDs_info.disenfIDs, 0 );
	end


	%% Return
	%
	output.STAT = STAT;
	output.SAC_uSTAT = SAC_uSTAT;
	output.uIDs_info = uIDs_info;

end