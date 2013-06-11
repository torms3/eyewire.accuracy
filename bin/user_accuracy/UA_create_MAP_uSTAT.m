function [uSTAT] = UA_create_MAP_uSTAT( UA, DB_MAPs )

% usernames & weight
usernames = extractfield(cell2mat(DB_MAPs.U.values),'username');
weight = extractfield(cell2mat(DB_MAPs.U.values),'weight');

% create a new list of data element
s_prec = UA.tp./(UA.tp + UA.fp);
s_rec = UA.tp./(UA.tp + UA.fn);
s_fs = 2*(s_prec.*s_rec)./(s_prec + s_rec);
v_prec = UA.tpv./(UA.tpv + UA.fpv);
v_rec = UA.tpv./(UA.tpv + UA.fnv);
v_fs = 2*(v_prec.*v_rec)./(v_prec + v_rec);

s_p1 = s_rec;
s_p0 = UA.tn./(UA.tn + UA.fp);
v_p1 = v_rec;
v_p0 = UA.tnv./(UA.tnv + UA.fpv);

s_a = log((s_p1.*s_p0)./((1 - s_p1).*(1 - s_p0)));
s_b = log((1 - s_p1)./s_p0);
v_a = log((v_p1.*v_p0)./((1 - v_p1).*(1 - v_p0)));
v_b = log((1 - v_p1)./v_p0);


%% Prepare cell arrays
%
n_seg = num2cell(UA.tp + UA.fn + UA.fp + UA.tn);
n_voxels = num2cell(UA.tpv + UA.fnv + UA.fpv + UA.tnv);

weight = num2cell(weight);
UA.nv  = num2cell(UA.nv);
UA.hot = num2cell(UA.hot);
UA.tp = num2cell(UA.tp);
UA.fn = num2cell(UA.fn);
UA.fp = num2cell(UA.fp);
UA.tn = num2cell(UA.tn);
UA.tpv = num2cell(UA.tpv);
UA.fnv = num2cell(UA.fnv);
UA.fpv = num2cell(UA.fpv);
UA.tnv = num2cell(UA.tnv);

s_prec = num2cell(s_prec);
s_rec = num2cell(s_rec);
s_fs = num2cell(s_fs);
v_prec = num2cell(v_prec);
v_rec = num2cell(v_rec);
v_fs = num2cell(v_fs);

s_p1 = num2cell(s_p1);
s_p0 = num2cell(s_p0);
v_p1 = num2cell(v_p1);
v_p0 = num2cell(v_p0);

s_a = num2cell(s_a);
s_b = num2cell(s_b);
v_a = num2cell(v_a);
v_b = num2cell(v_b);

vals = struct(  'username',usernames,'weight',weight,'nv',UA.nv,'hot',UA.hot, ...
				'n_seg',n_seg, ...
				'tp',UA.tp,'fn',UA.fn,'fp',UA.fp,'tn',UA.tn, ...
				'n_voxels',n_voxels, ...
				'tpv',UA.tpv,'fnv',UA.fnv,'fpv',UA.fpv,'tnv',UA.tnv, ...
				's_prec',s_prec,'s_rec',s_rec,'s_fs',s_fs, ...
				'v_prec',v_prec,'v_rec',v_rec,'v_fs',v_fs, ...
				's_p1',s_p1,'s_p0',s_p0,'s_a',s_a,'s_b',s_b, ...
				'v_p1',v_p1,'v_p0',v_p0,'v_a',v_a,'v_b',v_b ...
			 );
vals = mat2cell(vals,1,ones(1,numel(vals)));

% create an user accuracy MAP for cell_IDs
keys  = num2cell(UA.uID);
uSTAT = containers.Map( keys, vals );

end
