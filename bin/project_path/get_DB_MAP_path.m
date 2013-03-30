function [DB_MAP_path] = get_DB_MAP_path()

root_path = get_project_root_path();
DB_MAP_path = [root_path 'data/DB_MAPs/'];

end