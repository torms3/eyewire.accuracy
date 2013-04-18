function [DB_MAPs] = TUT_construct_DB_MAPs( uIDs )

%% Extract DB information
%
[TUT_U] 	= TUT_extract_tutorial_user_info( uIDs );
[TUT_V] 	= TUT_extract_tutorial_validation_info( uIDs );
[TUT_T] 	= TUT_extract_tutorial_task_info();
[chIDs] 	= extractfield( cell2mat(TUT_T.values), 'chID' );
[TUT_VOL] 	= TUT_extract_tutorial_volume_info( chIDs );


%% Post-processing
%
DB_extract_segment_info( TUT_T, TUT_VOL );


%% Return DB MAPs
%
DB_MAPs.U 	= TUT_U;
DB_MAPs.T 	= TUT_T;
DB_MAPs.V 	= TUT_V;
DB_MAPs.VOL = TUT_VOL;

end