function [V,tIDs] = user_validations( uID, period )

	%% Argument validation
	if( ~exist('period','var') )
	    period.since = '';
	    period.until = '';
	end

	% MySQL open
	mysql('open','127.0.0.1:13306','omnidev','we8pizza');
	mysql('use omniweb');

	% MySQL query
	query_str = ['SELECT validations.id,task_id,' ...
	             'segments,finish,weight ' ...
	             'FROM validations ' ...
	             'INNER JOIN tasks ON task_id=tasks.id ' ...
	            ];
	cell_IDs = [0];	% every cell
	t_status = [0];
	v_status = [0];
    [where_clause] = get_where_clause( cell_IDs, period, t_status, v_status );
	query_str = [query_str where_clause];
	query_str = [query_str 'AND (user_id=' num2str(uID) ') '];
	query_str = [query_str 'ORDER BY validations.id '];
	[vIDs,tIDs,seg,time,weight] = mysql( query_str );

	% MySQL close
	mysql('close');

	%% Extract validation information
	vals = {};
	nv = numel(vIDs);
	for i = 1:nv

	    fprintf('(%d/%d) validation (ID=%d) is now processing...\n',i,nv,vIDs(i));

	    vals{i}.tID = tIDs(i);	    
	    vals{i}.segs = segstr2seg( seg{i} );
	    vals{i}.finish = time{i};
	    vals{i}.datenum = datenum(time{i},'yyyy-mm-dd HH:MM:SS');
	    vals{i}.weight = weight(i);
	    
	end

	%% Task IDs
	keys = num2cell(vIDs);
	V = containers.Map(keys,vals);
	tIDs = unique(extractfield(cell2mat(vals),'tID'));

end