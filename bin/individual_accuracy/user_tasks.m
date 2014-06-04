function [T] = user_tasks( tIDs )

	%% Argument validation
	assert(~isempty(tIDs));
	tIDs = unique(tIDs);

	% MySQL open
	mysql('open','127.0.0.1:13306','omnidev','we8pizza');
	mysql('use omniweb');

	% MySQL query
	query_str = ['SELECT task_id,tasks.status,segments,seeds,channel_id,' ...
				 'cell,weight,created ' ...
             	 'FROM validations ' ...
             	 'INNER JOIN tasks ON task_id=tasks.id ' ...
             	 'WHERE (user_id=0) '
            	];
	tIDs_str = regexprep(num2str(unique(tIDs)),' +',',');
	query_str = [query_str 'AND tasks.id IN (' tIDs_str ') '];
	query_str = [query_str 'ORDER BY task_id '];
	[task,status,seg,seed,channel,cellIDs,weight,created] = mysql(query_str);

	% MySQL close
	mysql('close');

	% celltype information
	[MAP_celltype] = DB_create_MAP_celltype();

	%% Extract task information
	tasks = {};
	nt = numel(task);
	for i = 1:nt

		tID = task(i);
	    fprintf('(%d/%d) task (ID=%d) is now processing...\n',i,nt,tID);

	    tasks{i}.cell 	 = cellIDs(i);
	    tasks{i}.weight  = weight(i);
	    tasks{i}.status  = status(i);	    
	    tasks{i}.created = created{i};
	    tasks{i}.datenum = datenum(created{i},'yyyy-mm-dd HH:MM:SS');

	    [thresh] = get_celltype_threshold(weight(i),MAP_celltype(cellIDs(i)));
	    tasks{i}.consensus = sort(extract_consensus(seg{i},thresh),'ascend');

	    tasks{i}.union 	 = sort(segstr2seg(seg{i}),'ascend');
	    tasks{i}.seed 	 = sort(segstr2seg(seed{i}),'ascend');
	    tasks{i}.chID 	 = channel(i);
	    
	    % this field should be filled later
	    tasks{i}.seg_size = [];

	end

	keys = num2cell(task);
	T = containers.Map(keys,tasks);

end