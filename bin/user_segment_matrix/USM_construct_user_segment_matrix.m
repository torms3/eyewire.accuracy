function [USM_data] = USM_construct_user_segment_matrix( update, cell_IDs, period )

%% Argument validation
%
if( ~exist('cell_IDs','var') )
	cell_IDs = [0];
end
if( ~exist('period','var') )
	period.since = '';
	period.until = '';
end


%% Get DB_MAPs
%
save_path = DB_get_DB_MAP_path();
if( update )
	[DB_MAPs] = DB_construct_DB_MAPs( save_path, true, cell_IDs, period );
else
	[file_name] = make_DB_MAPs_file_name( cell_IDs, period );	
	load([save_path file_name]);
end


%% Create USM_data
%
[USM_meta,USM_data] = USM_create_user_segment_matrix( DB_MAPs );


%% Separately save the resulting USM_data due to the save size limit issue
%
% meta data
MAP_t_meta 		= USM_meta.MAP_t_meta;
MAP_user_seg 	= USM_meta.MAP_user_seg;
MAP_s_ui 		= USM_meta.MAP_s_ui;


%% Save
%
[save_path] = USM_get_data_path();
[save_dir] 	= USM_make_save_dir_name( cell_IDs, period );
mkdir(save_path,save_dir);

% meta data
var_name = 'MAP_t_meta';
save([save_path save_dir '/' var_name '.mat'],var_name);
var_name = 'MAP_user_seg';
save([save_path save_dir '/' var_name '.mat'],var_name);
var_name = 'MAP_s_ui';
save([save_path save_dir '/' var_name '.mat'],var_name);

% core data
var_name = 'USM_data';
save([save_path save_dir '/' var_name '.mat'],var_name);

end