function [ERR] = vanilla_parameters( uSTAT, USM_data, DB_MAPs )

%% Options
%
novice_control 	= true;
nonnegativity 	= false;


%% Extract vanilla parameters a and b for each EyeWirers
%
vals = cell2mat(uSTAT.values);
uID = cell2mat(uSTAT.keys)';
nv = extractfield( vals, 'nv' );
s_a = extractfield( vals, 's_a' );
s_b = extractfield( vals, 's_b' );
v_a = extractfield( vals, 'v_a' );
v_b = extractfield( vals, 'v_b' );

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


%% Prior
%
V = USM_data.V_i;
map_i_tID = USM_data.map_i_tID;
s_prior = zeros(1,nItems);
v_prior = zeros(1,nItems);

keys  	= DB_MAPs.T.keys;
vals 	= DB_MAPs.T.values;
for i = 1:DB_MAPs.T.Count

	tID = keys{i};
	fprintf('(%d/%d) tID = %d is now processing...\n',i,DB_MAPs.T.Count,tID);
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

% validation
s_prior(isnan(s_prior) | isinf(s_prior)) = 0;
v_prior(isnan(v_prior) | isinf(v_prior)) = 0;


%% Classification
%
S = USM_data.S_ui;
nItems = size(S,2);
sigma = USM_data.sigma;
IDX = S > -0.5;

[map_u_uID] = USM_get_map_user_idx_to_uID( DB_MAPs.U );
idx = ismember(uID,map_u_uID);
s_A = s_a(idx)*ones(1,nItems);
s_B = s_b(idx)*ones(1,nItems);
v_A = v_a(idx)*ones(1,nItems);
v_B = v_b(idx)*ones(1,nItems);

% supervoxel
SUM = sum(IDX.*(s_A.*S + s_B),1);
prediction = double((SUM + s_prior) > 0);
err = sigma - prediction;
[s_error] = compute_error( err, err, USM_data ); % compute error

% voxel
SUM = sum(IDX.*(v_A.*S + v_B),1);
prediction = double((SUM + v_prior) > 0);
err = sigma - prediction;
[v_error] = compute_error( err, err, USM_data ); % compute error

% default
[ERR_const,ERR_exp] = CM_compute_default_classifier_error( USM_data );


%% Return
%
ERR.s_error = s_error;
ERR.v_error = v_error;
ERR.const 	= ERR_const;
ERR.exp 	= ERR_exp;

end