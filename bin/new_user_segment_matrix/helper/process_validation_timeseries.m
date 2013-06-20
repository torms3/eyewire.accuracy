function [vTimeIdx] = process_validation_timeseries( V, nBins, binMode )

	finishTime = extractfield( cell2mat(V.values), 'datenum' );
	assert( issorted(finishTime) );

	vTimeIdx = zeros(1,V.Count);

	switch( binMode )
	case 'time'

		% [06/20/2013 kisuklee]
		%	TODO:
		%		implement

	case 'validation'

		binSize = double(ceil(V.Count/nBins));
		tails = binSize*(1:nBins);
		heads = tails - binSize + 1;
		
		for i = 1:nBins

			if( i == nBins )
				vTimeIdx(heads(i):end) = i;
			else
				vTimeIdx(heads(i):tails(i)) = i;
			end

		end

	otherwise
		assert( false );
	end

end