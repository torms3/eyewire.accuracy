function [output] = promotion_demotion( args, SAC, updateDB )

	%% Argument validation
	%
	if ~exist('updateDB','var')
		updateDB = false;
	end
	if ~exist('SAC','var')
		SAC = false;
	end


	%% Arguments
	%
	period 	 = args.period;
	t_status = args.t_status;


	%% Global
	%
	update = true;
	[STAT,STAT_per_cell] = process_user_stat( update, period, t_status );
	

	%% SAC
	%
	if SAC
		segInfo = true;
		cellIDs = [0];
		[SAC_DB_MAPs] = SAC_construct_DB_MAPs( segInfo, cellIDs, period, [0] );

		seed = false;
		[SAC_UA] = UA_process_user_accuracy( SAC_DB_MAPs, seed );
		[SAC_uSTAT] = UA_create_MAP_uSTAT( SAC_UA, SAC_DB_MAPs );
	end


	%% Exclude tracers from the analysis
	%
	[tracers] = DB_extract_tracer_uIDs();
	tracer_uIDs = tracers.keys;
	remove(STAT,tracer_uIDs);
	if SAC
		remove(SAC_uSTAT,tracer_uIDs);
	end

	
	%% Promotion/demotion info
	%
	[global_uIDs_info] = UA_plot_user_precision_recall_curve( STAT );
	if SAC
		[SAC_uIDs_info] = UA_plot_user_precision_recall_curve( SAC_uSTAT, 'sac' );
	end
	uIDs_info.global = global_uIDs_info;
	if SAC
		uIDs_info.SAC = SAC_uIDs_info;
	end


	%% User list
	%
	global_list.enf_uIDs = global_uIDs_info.enfIDs';
	global_list.enf_uNames = extractfield( cell2mat(values( STAT, num2cell(global_uIDs_info.enfIDs) )), 'username' )';

	global_list.disenf_uIDs = global_uIDs_info.disenfIDs';
	global_list.disenf_uNames = extractfield( cell2mat(values( STAT, num2cell(global_uIDs_info.disenfIDs) )), 'username' )';

	if SAC
		SAC_list.enf_uIDs = SAC_uIDs_info.enfIDs';
		SAC_list.enf_uNames = extractfield( cell2mat(values( STAT, num2cell(SAC_uIDs_info.enfIDs) )), 'username' )';

		SAC_list.disenf_uIDs = SAC_uIDs_info.disenfIDs';
		SAC_list.disenf_uNames = extractfield( cell2mat(values( STAT, num2cell(SAC_uIDs_info.disenfIDs) )), 'username' )';
	end


	%% Actual DB update
	%
	if( updateDB )
		DB_update_user_weight( global_uIDs_info.enfIDs, 1 );
		DB_update_user_weight( global_uIDs_info.disenfIDs, 0.1 );
		if SAC
			DB_update_cell_type_user_weight( 'sac', SAC_uIDs_info.enfIDs, 1 );
			DB_update_cell_type_user_weight( 'sac', SAC_uIDs_info.disenfIDs, 0.1 );
		end
	end


	%% Return
	%
	output.STAT = STAT;
	output.uIDs_info = uIDs_info;
	output.global_list = global_list;
	if SAC
		output.SAC_uSTAT = SAC_uSTAT;
		output.SAC_list = SAC_list;
	end


	%% Save
	%
	savePath = UA_get_data_path();
	saveDir = ['user_accuracy_' get_period_suffix( period )];
	UA_path = [savePath '/' saveDir];
	fname = 'output.mat';
	save([UA_path '/' fname],'output');

end