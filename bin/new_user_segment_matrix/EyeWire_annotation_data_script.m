function [] = EyeWire_annotation_data_script( DB_MAPs_path, save_path )

	file_list = dir([DB_MAPs_path '/' 'DB_MAPs__cell_*']);
	for i = 1:numel(file_list)

		file_name = file_list(i).name;
		disp(['Processing ' file_name '...']);
		cellID = sscanf(file_name,'DB_MAPs__cell_%d.mat');

		try
			% load DB_MAP
			load([DB_MAPs_path '/' file_name]);
		
			% construct data matrix
			skipV0 = false;
			skipSuperuser = true;
			[data] = NUSM_create_user_segment_matrix( DB_MAPs, skipV0, skipSuperuser );

			% save data matrix
			file_name_header = 'EyeWire_annotation_cell_';
			save([save_path '/' file_name_header num2str(cellID) '.mat'],'data','-v7.3');
		catch
			disp(['Skip ' file_name '...']);
			continue;
		end

	end

end