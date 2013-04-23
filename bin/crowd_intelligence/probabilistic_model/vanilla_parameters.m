function [ERR] = vanilla_parameters( uSTAT, data, DB_MAPs )

%% Options
%
novice_control 	= false;
nonnegativity 	= false;
prior_mode		= 'cube';
% prior_mode		= 'seg';
% prior_mode		= 'flat';


%% Extract vanilla parameters a and b for each EyeWirers
%
vals = cell2mat(uSTAT.values);
uID = cell2mat(uSTAT.keys)';
nv = extractfield( vals, 'nv' );
s_a = extractfield( vals, 's_a' )';
s_b = extractfield( vals, 's_b' )';
v_a = extractfield( vals, 'v_a' )';
v_b = extractfield( vals, 'v_b' )';

% validation
s_a(isnan(s_a) | isinf(s_a)) = 0;
s_b(isnan(s_b) | isinf(s_b)) = 0;
v_a(isnan(v_a) | isinf(v_a)) = 0;
v_b(isnan(v_b) | isinf(v_b)) = 0;


%% Novice control
%
if( novice_control )
	lower_nv = 100;
	idx = nv > lower_nv;
	s_a(~idx) = 0;
	s_b(~idx) = 0;
	v_a(~idx) = 0;
	v_b(~idx) = 0;
end


%% Nonnegativity constraints
%
if( nonnegativity )
	s_b(s_b > 0) = 0;
	v_b(v_b > 0) = 0;
	
	idx = (s_a + s_b) < 0;
	s_a(idx) = -s_b(idx);
	
	idx = (v_a + v_b) < 0;
	v_a(idx) = -v_b(idx);
end


%% Data
%
S = data.S_ui;
nUsers = size(S,1);
nItems = size(S,2);
V = data.V_i;
sigma = data.sigma;
IDX = S > -0.5;
map_i_tID = data.map_i_tID;
map_u_uID = data.map_u_uID;
n = sum(S > 0.5,1);
m = sum(IDX,1);


%% Prior
%
s_prior = zeros(1,nItems);
v_prior = zeros(1,nItems);

% cube-based prior
if( strcmp(prior_mode,'cube') )
	keys  	= DB_MAPs.T.keys;
	vals 	= DB_MAPs.T.values;
	for i = 1:DB_MAPs.T.Count

		tID = keys{i};
		% fprintf('(%d/%d) tID = %d is now processing...\n',i,DB_MAPs.T.Count,tID);
		tInfo = vals{i};

		seed = tInfo.seed;
		seg1 = setdiff(tInfo.consensus,seed);
		seg0 = setdiff(tInfo.union,[seg1 seed]);

		s_pri = log(numel(seg1)/numel(seg0));
		s_prior(ismember(map_i_tID,tID)) = s_pri;
		

		idx = ismember(tInfo.union,seg1);
		v_seg1 = tInfo.seg_size(idx);
		idx = ismember(tInfo.union,seg0);
		v_seg0 = tInfo.seg_size(idx);
		v_pri = log(sum(v_seg1)/sum(v_seg0));
		v_prior(ismember(map_i_tID,tID)) = v_pri;

	end

	decisive = log(n./(m - n));
	decisive = isinf(decisive).*decisive;
	s_prior = s_prior + decisive;
	v_prior = v_prior + decisive;
end

% supervoxel based prior
if( strcmp(prior_mode,'seg') )	
	s_prior = log( n./(m - n) );
	v_prior = s_prior;
end

% validation
% s_prior(isnan(s_prior) | isinf(s_prior)) = 0;
% v_prior(isnan(v_prior) | isinf(v_prior)) = 0;

if( strcmp(prior_mode,'flat') )
	s_prior(:) = 0;
	v_prior(:) = 0;
end


%% Classification
%
[~,IA,IB] = intersect(uID,map_u_uID);
s_A = zeros(nUsers,1);
s_B = zeros(nUsers,1);
v_A = zeros(nUsers,1);
v_B = zeros(nUsers,1);

s_A(IB) = s_a(IA);
s_B(IB) = s_b(IA);
v_A(IB) = v_a(IA);
v_B(IB) = v_b(IA);

s_A = s_A*ones(1,nItems);
s_B = s_B*ones(1,nItems);
v_A = v_A*ones(1,nItems);
v_B = v_B*ones(1,nItems);

% supervoxel
SUM = sum(IDX.*(s_A.*S + s_B),1);
prediction = double((SUM + s_prior) > 0);
err = sigma - prediction;
[s_error] = compute_error( err, err, data ); % compute error

% voxel
SUM = sum(IDX.*(v_A.*S + v_B),1);
prediction = double((SUM + v_prior) > 0);
err = sigma - prediction;
[v_error] = compute_error( err, err, data ); % compute error

% default
[ERR_const,ERR_exp] = CM_compute_default_classifier_error( data );


%% Return
%
ERR.s_error = s_error;
ERR.v_error = v_error;
ERR.const 	= ERR_const;
ERR.exp 	= ERR_exp;

end