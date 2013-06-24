function [global_uIDs_info] = NUSM_promotion_demotion( updateDB )

	%% Argument validation
	%
	if( ~exist('updateDB','var') )
		updateDB = false;
	end


	% period
	weekago = datestr(datenum(date)-7,'yyyy-mm-dd');
	today 	= datestr(datenum(date),'yyyy-mm-dd');
	midnight = '00:00:00';
	period.since = sprintf('''%s''',[weekago ' ' midnight]);
	period.until = sprintf('''%s''',[today ' ' midnight]);

	% save path
	DB_path = DB_get_DB_MAP_path();
	save_path = [DB_path '/with_segSize_info'];

	% construct DB MAPs
	cell_IDs = [0];
	t_status = [0];
	[DB_MAPs] = DB_construct_DB_MAPs( save_path, true, cell_IDs, period, t_status );

	% create user-segment matrix
	[data] = NUSM_create_user_segment_matrix( DB_MAPs, true );

	% global user accuracy
	[global_stat] = NUSM_compute_user_accuracy( data );
	[global_uIDs_info] =  NUSM_process_uIDs_for_promotion( global_stat, DB_MAPs.U );

	% SAC user accuracy
	% [SAC_stat] = NUSM_compute_SAC_user_accuracy( data );
	% [SAC_uIDs_info] = NUSM_process_uIDs_for_promotion( SAC_stat, DB_MAPs.U );


	%% Update DB
	%
	if( updateDB )
		% global weight
		DB_update_user_weight( global_uIDs_info.enfIDs, 1 );
		DB_update_user_weight( global_uIDs_info.disenfIDs, 0 );
		% SAC weight
		DB_update_cell_type_user_weight( 'sac', SAC_uIDs_info.enfIDs, 1 );
		DB_update_cell_type_user_weight( 'sac', SAC_uIDs_info.disenfIDs, 0 );

		% weekly global user accuracy
		[STAT] = NUSM_convert_stat_to_STAT( global_stat );
		period.since = weekago;
		period.until = today;
		DB_update_user_accuracy_info( STAT, period );
	end

end