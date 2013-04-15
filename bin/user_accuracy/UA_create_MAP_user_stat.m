function [STAT] = UA_create_MAP_user_stat( cell_IDs, period, DB_MAPs, UA_path )

%% Argument validation
%
if( ~exist('cell_IDs','var') )
	cell_IDs = [0];
end
if( ~exist('period','var') )
	period.since = '';
	period.until = '';
end
if( ~exist('DB_MAPs','var') )
	[DB_path] = DB_get_DB_MAP_path();
	[file_name] = make_DB_MAPs_file_name( cell_IDs, period );
	full_path = [DB_path file_name];
	try
		load(full_path);
	catch err
		disp(err);
	end
end
if( ~exist('UA_path','var') )
	[UA_path] = UA_get_data_path();
end


% load user accuracy information
cell_IDs_str = regexprep(num2str(unique(cell_IDs)),' +','_');
file_name = sprintf('user_accuracy__cell_%s.dat',cell_IDs_str);
user_stat = extract_user_stat( [UA_path file_name] );

% load MAP_u_info for extracting usernames
% full_path = get_DB_MAP_path( cell_IDs );


% user ID validation
invalid_idx = find(user_stat.id == 0);
user_stat.id(invalid_idx,:) = [];

% usernames & weight
usernames = extractfield(cell2mat(DB_MAPs.U.values),'username')';
weight = num2cell(extractfield(cell2mat(DB_MAPs.U.values),'weight')');

% create a new list of data element
% 1:id, 2:tp, 3:fn, 4:fp, 5:nv 6:tpv 7:fnv 8:fpv 9:hot
M = user_stat.original_matrix(:,2:9);
seg_prec = user_stat.tp./(user_stat.tp + user_stat.fp);
seg_rec = user_stat.tp./(user_stat.tp + user_stat.fn);
v_prec = user_stat.tpv./(user_stat.tpv + user_stat.fpv);
v_rec = user_stat.tpv./(user_stat.tpv + user_stat.fnv);
seg_fs = 2*(seg_prec.*seg_rec)./(seg_prec + seg_rec);
v_fs = 2*(v_prec.*v_rec)./(v_prec + v_rec);
M = [M seg_prec seg_rec seg_fs v_prec v_rec v_fs];
M(invalid_idx,:) = [];
C = mat2cell(M,ones(1,size(M,1)),ones(1,size(M,2)));
vals = struct('username',usernames, ...
			  'tp',C(:,1),'fn',C(:,2),'fp',C(:,3),'nv',C(:,4), ...
			  'tpv',C(:,5),'fnv',C(:,6),'fpv',C(:,7), ...
			  'hot',C(:,8), ...
			  'seg_prec',C(:,9),'seg_rec',C(:,10),'seg_fs',C(:,11), ...
			  'v_prec',C(:,12),'v_rec',C(:,13),'v_fs',C(:,14), ...
			  'weight',weight ...
			 );
vals = mat2cell(vals,ones(1,size(vals,1)),1);

% create an user accuracy MAP for cell_IDs
keys = num2cell(user_stat.id);
STAT = containers.Map( keys, vals );

end
