function [] = NCM_script_hotspot_volume( dataPath )

	flist = dir(dataPath);
	for i = 1:numel(flist)

		if( flist(i).isdir )
			continue;
		end

		fileName = flist(i).name;
		disp([fileName ' is now being processed...']);
		load(fileName);

		DB_MAPs.V.

	end

end