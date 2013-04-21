function PM_batch_script( root_path, data, iter, K )

%% normal eta setting
%
partition_mode = 'segment';
save_path = [root_path '/' partition_mode '_partition'];
[setting] = CM_prepare_setting( 0.01, iter );
PM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.02, iter );
PM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.05, iter );
PM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.1, iter );
PM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.15, iter );
PM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.2, iter );
PM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );

partition_mode = 'task';
save_path = [root_path '/' partition_mode '_partition'];
[setting] = CM_prepare_setting( 0.01, iter );
PM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.02, iter );
PM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.05, iter );
PM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.1, iter );
PM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.15, iter );
PM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );
[setting] = CM_prepare_setting( 0.2, iter );
PM_K_fold_cross_validation( save_path, data, setting, K, partition_mode );

end