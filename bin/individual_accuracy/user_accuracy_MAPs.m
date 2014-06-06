function [MAPs] = user_accuracy_MAPs( username, period )

	%% Argument validation
	if( ~exist('period','var') )
	    period.since = '';
	    period.until = '';
	end

	%% Extract user ID
	[~,name_ID] = DB_create_MAP_uID_uName();
	uID = name_ID(username);

	%% Extract user validation info
	[V,tIDs] = user_validations(uID,period);

	%% Extract task info
	[T] = user_tasks(tIDs);

	%% Extract channel info
	[chIDs]	= extractfield(cell2mat(T.values),'chID');
	[VOL]	= DB_extract_volume_info(chIDs);
	DB_extract_segment_info(T,VOL);

	%% Return
	MAPs.V 	 = V;
	MAPs.T 	 = T;
	MAPs.VOL = VOL;

end