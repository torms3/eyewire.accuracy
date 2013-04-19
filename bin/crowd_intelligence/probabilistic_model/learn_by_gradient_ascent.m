function [params,prof] = learn_by_gradient_ascent( full_s1, full_s0 )

%% Profiling parameters
%
profile_on = false;

%% Parameter inititalization
%
params = initialize_parameters( full_s1, full_s0 );

%% Iteration
%
tic

period = 10;
iterations = 50;
if( profile_on )
	prof = make_params_profile( params, iterations, period );
end

n1 = numel(params.s1);
n0 = numel(params.s0);
for epoch = 1:iterations
	
	% sigma = 1
	for idx = 1:n1

		s = params.s1(idx);
		u = params.u1(idx);
		i = params.i1(idx);

		error = s - logistic( params.a(u)*params.alpha(i) );
		params.a(u) = params.a(u) + params.eta*params.alpha(i)*error;		
		params.alpha(i) = params.alpha(i) + params.eta*params.a(u)*error;
				
	end

	% sigma = 0
	for idx = 1:n0
		
		s = params.s0(idx);
		u = params.u0(idx);
		i = params.i0(idx);

		error = s - logistic( params.b(u)*params.beta(i) );
		params.beta(i) = params.beta(i) + params.eta*params.b(u)*error;
		params.b(u) = params.b(u) + params.eta*params.beta(i)*error;

	end

	% log-likelihood (should increase)
	if( mod(epoch,period) == 0 )
		%y(epoch) = log_likelihood( params );
		%fprintf('%dth epoch: log-likelihood = %f\n',epoch,y(epoch));

		% update params profile
		if( profile_on )
			prof = update_params_profile( params, prof, floor(epoch/period) );
		end
	end

	fprintf('%dth epoch done\n',epoch);

end

toc

%plot(1:iterations,y);

%% Inspect and save the resulting parameters
%
%inspect_parameters( prof );
if( profile_on )
	save( './params.mat', 'params','prof' );
else
	save( './params.mat', 'params' );
end

end


function [val] = log_likelihood( params )

val = 0;

% sigma = 1
n1 = numel(params.s1);
for idx = 1:n1

	s = params.s1(idx);
	u = params.u1(idx);
	i = params.i1(idx);

	term = params.a(u)*params.alpha(i);
	val = val + (term*s - log(exp(term)+1));

end

% sigma = 0
n0 = numel(params.s0);
for idx = 1:n0
	
	s = params.s0(idx);
	u = params.u0(idx);
	i = params.i0(idx);

	term = params.b(u)*params.beta(i);
	val = val + (term*s - log(exp(term)+1));
	
end

end