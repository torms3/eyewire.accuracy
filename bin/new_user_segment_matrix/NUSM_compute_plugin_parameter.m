function [a,b] = NUSM_compute_plugin_parameter( data, stat )

	p1 = zeros(size(stat.uIDs));
	p2 = zeros(size(stat.uIDs)); % p1/p0
	a  = zeros(size(stat.uIDs));
	b  = zeros(size(stat.uIDs));
	
	% P(sigma=1)/P(sigma=0)
	Ps1s0 = nnz(data.sigma)/(numel(data.sigma) - nnz(data.sigma));
	Ps0s1 = 1/Ps1s0;

	% compute probabilities
	p1 = stat.vRec;
	p2 = (stat.vPrec*Ps0s1)./(1 - stat.vPrec);
	
	% compute multiplicative coefficiant & additive bias	
	b = log((1 - p1)./(1 - p1.*(1./p2)));
	a = log(p2) - b;

	% validation
	idx = isnan(a) | isinf(a) | (a < 0);
	a(idx) = 0;
	idx = isnan(b) | isinf(b) | (b > 0);
	b(idx) = 0;

end