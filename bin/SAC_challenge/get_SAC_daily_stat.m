function [daily_stat] = get_SAC_daily_stat( DB_MAPs )

n_MAPs = numel(DB_MAPs);
daily_stat = cell(n_MAPs,1);

% extract daily stat
for i = 1:n_MAPs

	[daily_stat{i}] = extract_SAC_daily_stat( DB_MAPs{i} );

end

end


function [daily_stat] = extract_SAC_daily_stat( DB_MAPs )

% validations
V = cell2mat(DB_MAPs.V.values);
finish_time = extractfield(V,'datenum');
uID = extractfield(V,'uID');
tID = extractfield(V,'tID');
weight = extractfield(V,'weight');

% cubes
T = cell2mat(DB_MAPs.T.values);
created = extractfield(T,'datenum');
tIDs = cell2mat(DB_MAPs.T.keys);

% SAC challenge date
start_date = datenum('2013-03-15 00:00:00','yyyy-mm-dd HH:MM:SS');
end_date = datenum(date);
n_days = end_date - start_date + 1;

nv = zeros(1,n_days);			% daily validations
nv_w1 = zeros(1,n_days);		% nv, with weight=1
nv_w0 = zeros(1,n_days);		% nv, with weight=0
new_nv = zeros(1,n_days);		% daily validations for daily new tasks
new_nv_w1 = zeros(1,n_days);	% new_nv, with weight = 1
new_nv_w0 = zeros(1,n_days);	% new_nv, with weight = 0
nt = zeros(1,n_days);			% daily cubes
new_nt = zeros(1,n_days);		% daily new cubes 
nu = zeros(1,n_days);			% daily participants
nuv = cell(1,n_days);			% user-wise daily validations 
mode_uID = zeros(1,n_days);		% daily top user in terms of nv
uIDs = cell(1,n_days);			% daily participants list

% extract daily stat
for i = 1:n_days

	from = start_date + i - 1;
	to = start_date + i;
	
	% index for validations
	v_today_idx = (finish_time >= from) & (finish_time < to);
	v_w1_idx = logical(weight);
	
	% index for cubes
	t_today_idx = (created >= from) & (created < to);
	new_tIDs = tIDs(t_today_idx);
	
	% validations
	nv(i) = nnz(v_today_idx);
	nv_w1(i) = nnz(v_today_idx & v_w1_idx);
	nv_w0(i) = nv(i) - nv_w1(i);
	
	% cubes
	% cubes that are affected today, validation perspective
	today_tIDs = tID(v_today_idx);
	% cubes that are affected by valid validations today
	today_tIDs_w1 = tID(v_today_idx & v_w1_idx);
	% cubes that are affected today, cube perspective
	unique_tIDs = unique(today_tIDs);
	
	nt(i) = nnz(unique_tIDs);
	% new_nt(i) = nnz(intersect(new_tIDs,unique_tIDs));
	new_nt(i) = numel(new_tIDs);
	
	new_nv(i) = nnz(ismember(today_tIDs,new_tIDs));
	new_nv_w1(i) = nnz(ismember(today_tIDs_w1,new_tIDs));
	new_nv_w0(i) = new_nv(i) - new_nv_w1(i);

	% users
	today_uIDs = uID(v_today_idx);
	uIDs{i} = unique(today_uIDs);
	nu(i) = numel(uIDs{i});	

	n = histc(today_uIDs,uIDs{i});	
	nuv{i} = sort(n,'descend');

	mode_uID(i) = mode(today_uIDs);

end

daily_stat.n_days = n_days;
% validations
daily_stat.nv = nv;
daily_stat.nv_w1 = nv_w1;
daily_stat.nv_w0 = nv_w0;
daily_stat.new_nv = new_nv;
daily_stat.new_nv_w1 = new_nv_w1;
daily_stat.new_nv_w0 = new_nv_w0;
% cubes
daily_stat.nt = nt;
daily_stat.new_nt = new_nt;
% users
daily_stat.nu = nu;
% user-wise
daily_stat.nuv = nuv;
daily_stat.mode_uID = mode_uID;
daily_stat.uIDs = uIDs;

end