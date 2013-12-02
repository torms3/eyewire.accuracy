
file_list = dir(filePath);
for i = 1:numel(file_list)

	if( file_list(i).isdir )
		continue;
	end

	fileName = file_list(i).name;
	disp([fileName ' is now being processed...']);
	load(fileName);

	% userForThisCell = cell2mat(DB_MAPs.U.keys());
	% newUser = setdiff(userForThisCell,user);
	% disp(['Numer of new users: ' num2str(numel(newUser))]);
	% disp(['Number of existing users: ' num2str(numel(userForThisCell)-numel(newUser))]);	
	% user = union(user,userForThisCell);

	[data] = NUSM_create_user_segment_matrix( DB_MAPs );
	if( ~exist('param','var') )
		[param] = NCM_train_classifier( savePath, data, setting );
	else	
		[param] = NCM_train_classifier( savePath, data, setting, param );
	end

end