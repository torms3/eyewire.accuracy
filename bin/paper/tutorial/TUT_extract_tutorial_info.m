function [TUT_INFO] = TUT_extract_tutorial_info()

%% MySQL
%
% MySQL open
mysql('open','127.0.0.1:13306','omnidev','we8pizza');
mysql('use omniweb');

% MySQL query
query_str = ['SELECT task_id,difficulty,sequence,celltype ' ...
         	 'FROM tutorials ' ...
        	];
[tIDs,difficulty,seq,celltype] = mysql( query_str );

% MySQL close
mysql('close');


%% Extract tutorial information
%
for i = 1:numel(tIDs)
    
    vals{i}.difficulty = difficulty(i);
    vals{i}.sequence = seq(i);
    vals{i}.celltype = celltype{i};
    
end

keys = num2cell(tIDs);
TUT_INFO = containers.Map( keys, vals );

end