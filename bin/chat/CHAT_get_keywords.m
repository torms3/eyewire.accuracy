function [keywords] = CHAT_get_keywords()

	keywords = cell(1);

	% questions
	question = cell(1);
	question{end} 	= upper('\<how\>');
	question{end+1} = upper('\<why\>');
	question{end+1} = upper('\<what\>');
	question{end+1} = upper('\<when\>');
	question{end+1} = upper('\<where\>');
	question{end+1} = upper('?');
	keywords{end} 	= question;

	% url
	url = cell(1);
	url{end} 		= upper('http');
	url{end+1} 		= upper('\.com');
	url{end+1} 		= upper('://');
	keywords{end+1} = url;
	
	% phrases
	keywords{end+1} = {upper('\<eyewire is\>')};
	keywords{end+1} = {upper('\<i think\>')};
	keywords{end+1} = {upper('\<i am\>')};

end