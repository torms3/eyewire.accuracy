function [] = extract_simulated_data( tInfo, V )

u_seg = tInfo.union;
c_seg = tInfo.consensus;
s_seg = tInfo.seed;

vIDs = tInfo.vIDs;
vInfos = values( V, num2cell(vIDs) );
w = extractfield( cell2mat(vInfos), 'weight' );
valid_idx = (w == 1);

sigma = zeros(1,numel(u_seg));
sigma(ismember(u_seg,c_seg)) = 1;

S_ui = zeros(nnz(valid_idx),numel(u_seg));


end