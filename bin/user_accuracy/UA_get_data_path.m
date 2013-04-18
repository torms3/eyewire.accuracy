function [UA_data_path] = UA_get_data_path()

root_path = get_project_root_path();
UA_data_path = [root_path '/data/user_accuracy'];

end