function [vals] = CHAT_scrape( CHAT, keywords )

% for comparison
msg = upper(CHAT.msg);

% search
for i = 1:numel(keywords)

	idx = logical(zeros(size(CHAT.msg)));

	key_group = keywords{i};
	for j = 1:numel(key_group)

		key = key_group{j};
		[empty_idx] = cellfun(@isempty,regexp(msg,key));
		idx = idx | ~empty_idx;

	end

	vals{i} = CHAT.msg(idx);

end

% MAP_scrape = containers.Map( keywords, vals );

end