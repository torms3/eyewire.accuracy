function [TUT_STAT] = compute_tutorial_user_accuracy( DB_MAPs, TUT_INFO )

%% User-wise processing
%
keys 	= DB_MAPs.U.keys;
for i = 1:DB_MAPs.U.Count

	uID = keys{i};
	fprintf('%dth user (user_id=%d) is now processing...\n',i,uID);

	% compute user accuracy
	[user_info] = TUT_process_each_user( uID, DB_MAPs, TUT_INFO );

	% Data Element
	vals{i} = user_info;

end


%% Create and return a MAP for user accuracy
%
TUT_STAT = containers.Map( keys, vals );

end


function [user_info] = TUT_process_each_user( uID, DB_MAPs, TUT_INFO )

U   = DB_MAPs.U;
T   = DB_MAPs.T;
V   = DB_MAPs.V;
VOL = DB_MAPs.VOL;

uInfo = U(uID);
vIDs = uInfo.vIDs;
nv = numel(vIDs);
user_info = cell(1,nv);
for i = 1:nv

	% validation information
	vID = vIDs(i);
	vInfo = V(vID);
	duration = vInfo.duration;

	% task information
	tID = vInfo.tID;
	tInfo = T(tID);

	% tutorial information	
	difficulty = TUT_INFO(tID).difficulty;
	sequence = TUT_INFO(tID).sequence;
	celltype = TUT_INFO(tID).celltype;

	% volume information
	chID = tInfo.chID;
	volInfo = VOL(chID);

	[match,miss,extra] = process_each_validation( vInfo, tInfo );

	% number of segments
    tp = numel(match);
    fn = numel(miss);
    fp = numel(extra);

    % number of voxels (segment volume)
    tpv = sum(get_size_of_segments( volInfo, match ));
    fnv = sum(get_size_of_segments( volInfo, miss ));
    fpv = sum(get_size_of_segments( volInfo, extra ));

    user_info{i}.tp = tp;
    user_info{i}.fn = fn;
    user_info{i}.fp = fp;
    user_info{i}.tpv = tpv;
    user_info{i}.fnv = fnv;
    user_info{i}.fpv = fpv;
    user_info{i}.duration = duration;
    user_info{i}.difficulty = difficulty;
    user_info{i}.sequence = sequence;
    user_info{i}.celltype = celltype;

end

end