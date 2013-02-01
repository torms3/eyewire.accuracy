function [match,miss,extra] = process_each_validation( validation_info, MAP_t_info )

% initialization
match   = [];
miss    = [];
extra   = [];

% validation segments
segments = validation_info.segments;

% task segment info
task_id = validation_info.task_id;
consensus = MAP_t_info(task_id).consensus;
seed = MAP_t_info(task_id).seed;

% do not consider seed segments
segments = setdiff( segments, seed );
consensus = setdiff( consensus, seed );

% Compare
match   = intersect( segments, consensus );
miss    = setdiff( consensus, segments );
extra   = setdiff( segments, consensus );

end