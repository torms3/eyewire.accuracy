function [match,miss,extra] = process_each_validation( V, T )

% initialization
match   = [];
miss    = [];
extra   = [];

% validation segments
seg 	= V.segs;

% task segment info
c_seg 	= T.consensus;
seed 	= T.seed;

% do not consider seed segments
seg 	= setdiff( seg, seed );
c_seg 	= setdiff( c_seg, seed );

% compare
match   = intersect( seg, c_seg );
miss    = setdiff( c_seg, seg );
extra   = setdiff( seg, c_seg );

end