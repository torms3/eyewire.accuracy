function [USM_data_path] = USM_get_data_path()

root_path = get_project_root_path();
USM_data_path = [root_path '/data/user_segment_matrix'];

end