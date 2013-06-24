function [uIDs_info] =  NUSM_process_uIDs_for_promotion( stat, U, cell_type )

	%% Argument validation
	%
	if( ~exist('cell_type','var') )
	    cell_type = 'any';
	end	
    switch( cell_type )
    case 'sac'
        cut_line.prec   = 0.8;
        cut_line.rec    = 0.8;
    otherwise
        cut_line.prec   = 0.7;
        cut_line.rec    = 0.7;
    end


    %% Data validation
    %
	valid_idx = ~(isnan(stat.vPrec) | isnan(stat.vRec));	
	[vPrec] = stat.vPrec(valid_idx)';
	[vRec]  = stat.vRec(valid_idx)';


	%% Stat
	%
	uIDs = stat.uIDs(valid_idx);
	nUser = numel(uIDs);
	good_idx = (vPrec > cut_line.prec) & (vRec > cut_line.rec);
	bad_idx  = ~good_idx; 
	nGood = nnz(good_idx);
	nBad = nUser - nGood;
	assert( nBad == nnz(bad_idx) );
	goodIDs = uIDs(good_idx);
	badIDs = uIDs(bad_idx);

	% weight
	vals = values( U, num2cell(uIDs) );
	[w] = extractfield( cell2mat(vals), 'weight' );
	% overwriting SAC-specific weight
	if( strcmp(cell_type,'sac') )
	    [SAC_uIDs,SAC_w] = DB_extract_cell_type_specific_weight( cell_type );
	    [~,ia,ib] = intersect(uIDs,SAC_uIDs);
	    w(ia) = SAC_w(ib);
	end

	% # cubes 
	[nv] = extractfield( cell2mat(vals), 'nv' );
	switch( cell_type )
	case 'sac'
	    nv_filter = nv > 20;
	otherwise
	    nv_filter = nv > 0;
	end
	enf = good_idx & (w == 0) & nv_filter;
	disenf = bad_idx & (w == 1);
	[enfIDs] = uIDs(enf);
	if( strcmp(cell_type,'any') )
	    [enfIDs] = qualify_enfranchisement_candidates( enfIDs );
	end
	disenfIDs = uIDs(disenf);

	fprintf('%d out of %d users (%.2f %%) are above the cut-line.\n',nGood,nUser,nGood*100.0/nUser);
	fprintf('%d out of %d users (%.2f %%) are below the cut-line.\n',nBad,nUser,nBad*100.0/nUser);
	fprintf('%d users (%.2f %%) will be enfranchised.\n',numel(enfIDs),numel(enfIDs)*100.0/nUser);
	fprintf('%d users (%.2f %%) will be disenfranchised.\n',nnz(disenf),nnz(disenf)*100.0/nUser);

	uIDs_info.goodIDs   = goodIDs;
	uIDs_info.badIDs    = badIDs;
	uIDs_info.enfIDs    = enfIDs;
	uIDs_info.disenfIDs = disenfIDs;

end