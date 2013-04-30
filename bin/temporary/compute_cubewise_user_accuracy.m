function [STAT] = compute_cubewise_user_accuracy( DB_MAPs )

%% Extract hotspot cube IDs
%
[hotspot_IDs,~] = get_VT_hotspots( DB_MAPs.V, DB_MAPs.T );


%% User-wise processing
%
keys 	= DB_MAPs.U.keys;
for i = 1:DB_MAPs.U.Count

	uID = keys{i};
	fprintf('%dth user (user_id=%d) is now processing...\n',i,uID);

	% CWUA stands for 'Cube-Wise User Accuracy'
	[user_info] = CWUA_process_each_user( uID, DB_MAPs, hotspot_IDs );

	% Data Element
	vals{i} = user_info;

end


%% Create and return a MAP for user accuracy
%
STAT = containers.Map( keys, vals );

end


function [user_info] = CWUA_process_each_user( uID, DB_MAPs, hotspot_IDs )

%% Initialization
%
U   = DB_MAPs.U;
T   = DB_MAPs.T;
V   = DB_MAPs.V;
VOL = DB_MAPs.VOL;

uInfo = U(uID);
vIDs = uInfo.vIDs;
nv = numel(vIDs);

user_info.nv   = nv;
user_info.tp   = zeros(1,nv);
user_info.fn   = zeros(1,nv);
user_info.fp   = zeros(1,nv);
user_info.tpv  = zeros(1,nv);
user_info.fnv  = zeros(1,nv);
user_info.fpv  = zeros(1,nv);
user_info.hot  = zeros(1,nv);
user_info.cell = zeros(1,nv);

user_info.v_prec = zeros(1,nv);
user_info.v_rec = zeros(1,nv);
user_info.v_fs = zeros(1,nv);

user_info.datenum = zeros(1,nv);


%% Cube-wise processing
%
for i = 1:numel(vIDs)

    % validation information
	vID = vIDs(i);
	vInfo = V(vID);

    % task information
	tID = vInfo.tID;
	tInfo = T(tID);

    % volume information
    chID = tInfo.chID;
    volInfo = VOL(chID);

	% [match,miss,extra] = process_each_validation( vInfo, tInfo );
    [VA] = process_each_validation( vInfo, tInfo, false );
    match = VA.tp;
    miss  = VA.fn;
    extra = VA.fp;

	% number of segments
    user_info.tp(i) = numel(match);
    user_info.fn(i) = numel(miss);
    user_info.fp(i) = numel(extra);

    % number of voxels (segment volume)
    u_seg = tInfo.union;
    idx = ismember(u_seg,match);
    user_info.tpv(i) = sum(tInfo.seg_size(idx));
    idx = ismember(u_seg,miss);
    user_info.fnv(i) = sum(tInfo.seg_size(idx));
    idx = ismember(u_seg,extra);
    user_info.fpv(i) = sum(tInfo.seg_size(idx));
    % user_info.tpv(i) = sum(get_size_of_segments( volInfo, match ));
    % user_info.fnv(i) = sum(get_size_of_segments( volInfo, miss ));
    % user_info.fpv(i) = sum(get_size_of_segments( volInfo, extra ));

    % hotspot cubes
    if( ~isempty(find(hotspot_IDs == tID)) )
        user_info.hot(i) = 1;
    end

    % accuracy
    user_info.v_prec(i) = user_info.tpv(i)/(user_info.tpv(i) + user_info.fpv(i));
    user_info.v_rec(i) = user_info.tpv(i)/(user_info.tpv(i) + user_info.fnv(i));
    user_info.v_fs(i) = 2*(user_info.v_prec(i)*user_info.v_rec(i))/(user_info.v_prec(i) + user_info.v_rec(i));

    % datenum
    user_info.datenum(i) = vInfo.datenum;
    user_info.cell(i) = tInfo.cell;

end

end