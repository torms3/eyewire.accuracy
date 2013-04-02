
%% normal eta setting
%
iter = 100;
root_path = '/Users/kisuklee/Workbench/seung-lab/eyewire.accuracy/data/crowd_intelligence/classifier_model/cell_10/nonnegativity_model/';

partition_mode = 'segment';
save_path = [root_path partition_mode '_partition/'];
[setting] = CM_prepare_setting( 0.01, iter );
CM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.02, iter );
CM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.05, iter );
CM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.1, iter );
CM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.15, iter );
CM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.2, iter );
CM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );

partition_mode = 'task';
save_path = [root_path partition_mode '_partition/'];
[setting] = CM_prepare_setting( 0.01, iter );
CM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.02, iter );
CM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.05, iter );
CM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.1, iter );
CM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.15, iter );
CM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.2, iter );
CM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );


%% eta setting for linear-dependence on segment volume
%
% [setting] = CM_prepare_setting( 0.000001, iter );
% CM_K_fold_cross_validation( save_path, data, setting, K, map_tIDs );
% [setting] = CM_prepare_setting( 0.000002, iter );
% CM_K_fold_cross_validation( save_path, data, setting, K, map_tIDs );
% [setting] = CM_prepare_setting( 0.000005, iter );
% CM_K_fold_cross_validation( save_path, data, setting, K, map_tIDs );
% [setting] = CM_prepare_setting( 0.00001, iter );
% CM_K_fold_cross_validation( save_path, data, setting, K, map_tIDs );
% [setting] = CM_prepare_setting( 0.00002, iter );
% CM_K_fold_cross_validation( save_path, data, setting, K, map_tIDs );
% [setting] = CM_prepare_setting( 0.00005, iter );
% CM_K_fold_cross_validation( save_path, data, setting, K, map_tIDs );