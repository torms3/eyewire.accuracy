function [DB_MAPs] = DB_construct_DB_MAPs( save_path, b_seg_info, cell_IDs, period )

%% Argument validation
%
if( ~exist('b_seg_size','var') )
	b_seg_size = true;
end
if( ~exist('cell_IDs','var') )
	cell_IDs = [0];
end
if( ~exist('period','var') )
	period.since = '';
	period.until = '';
end


%% Extract DB information
%
[U] 	= DB_extract_user_info( cell_IDs, period );
[T] 	= DB_extract_task_info( cell_IDs, period );
[V] 	= DB_extract_validation_info( cell_IDs, period );
[chIDs]	= extractfield( cell2mat(T.values), 'chID' );
[VOL]	= DB_extract_volume_info( chIDs );


%% Post-processing
%
if( b_seg_size )
	% pass by reference; no output needed
	DB_extract_segment_info( T, VOL );
end


%% Return DB MAPs
%
DB_MAPs.U 	= U;
DB_MAPs.T 	= T;
DB_MAPs.V 	= V;
DB_MAPs.VOL = VOL;	


%% Save as a file
%
[file_name] = make_DB_MAPs_file_name( cell_IDs, period );
full_path = [save_path '/' file_name];
save(full_path,'DB_MAPs');

end