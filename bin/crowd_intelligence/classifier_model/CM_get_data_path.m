function [CM_data_path] = CM_get_data_path()

root_path = get_project_root_path();
CM_data_path = [root_path 'data/crowd_intelligence/classifier_model/'];

end