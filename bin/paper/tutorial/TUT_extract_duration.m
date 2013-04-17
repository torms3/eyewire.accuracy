function [uIDs,user_stat] = TUT_extract_duration( TUT_STAT )

%% User-wise processing
%
user_dur = cell(TUT_STAT.Count,1);
user_prec = cell(TUT_STAT.Count,1);
user_rec = cell(TUT_STAT.Count,1);
user_fs = cell(TUT_STAT.Count,1);
uIDS = cell(TUT_STAT.Count,1);

keys 	= TUT_STAT.keys;
vals 	= TUT_STAT.values;
for i = 1:TUT_STAT.Count

	uID = keys{i};
	val = vals{i};
	dur = extractfield( cell2mat(val), 'duration' );
	dif = extractfield( cell2mat(val), 'difficulty' );
	tpv = extractfield( cell2mat(val), 'tpv' );
	fnv = extractfield( cell2mat(val), 'fnv' );
	fpv = extractfield( cell2mat(val), 'fpv' );

	idx = (dif == 0);
	if( nnz(idx) < 9 )
		continue;
	end

	uIDs{i} = uID;
	user_dur{i} = dur(idx);
	user_prec{i} = tpv(idx)./(tpv(idx) + fpv(idx));
	user_rec{i} = tpv(idx)./(tpv(idx) + fnv(idx));
	user_fs{i} = 2*(user_prec{i}.*user_rec{i})./(user_prec{i} + user_rec{i});

end

uIDs = cell2mat(uIDs);

user_dur = cell2mat(user_dur);
user_prec = cell2mat(user_prec);
user_rec = cell2mat(user_rec);
user_fs = cell2mat(user_fs);

user_stat.user_dur = user_dur;
user_stat.user_prec = user_prec;
user_stat.user_rec = user_rec;
user_stat.user_fs = user_fs;

end