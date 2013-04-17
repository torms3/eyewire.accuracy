function [uIDs] = qualify_enfranchisement_candidates( enfIDs, U, th )

if( ~exist('U','var') )
	[U] = DB_extract_user_info();
end

if( ~exist('th','var') )
	th = 100;
end


uIDs = [];
for i = 1:numel(enfIDs)

	uID = enfIDs(i);
	if( ~isKey( U, uID ) )
		continue;
	end
	if( numel(U(uID).vIDs) > th )
		uIDs = [uIDs uID];
	end

end

end