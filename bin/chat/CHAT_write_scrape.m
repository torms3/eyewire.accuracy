function CHAT_write_scrape( vals )

root_path = get_project_root_path();
file_path = [root_path 'bin/chat/'];
file_name = 'test.txt';
fp = fopen([file_path file_name],'w');

for i = 1:numel(vals)

	msg_list = vals{i};
	for j = 1:numel(msg_list)

		fprintf(fp,[msg_list{j} '\n']);

	end

	fprintf(fp,'\n\n\n');

end

fclose(fp);

end