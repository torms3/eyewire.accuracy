
filtered = cell(size(stats));
for i = 1:numel(stats)

	idx = stats{i}.nv >= 20;
	filtered{i}.username = stats{i}.username(idx);
	filtered{i}.nv = stats{i}.nv(idx);
	filtered{i}.tpv = stats{i}.tpv(idx);
	filtered{i}.fnv = stats{i}.fnv(idx);
	filtered{i}.fpv = stats{i}.fpv(idx);
	filtered{i}.v_prec = stats{i}.v_prec(idx);
	filtered{i}.v_rec = stats{i}.v_rec(idx);
	filtered{i}.v_fs = stats{i}.v_fs(idx);

end

% % MySQL open
% mysql('open','127.0.0.1:13306','omnidev','we8pizza');
% mysql('use omniweb');

% query = ['SELECT DISTINCT(tasks.id) FROM tasks INNER JOIN cells ON cells.id=tasks.cell ' ...
% 		 'WHERE tasks.status=0 and cells.celltype=''sac'' '];
% SAC_tIDs2 = mysql(query);
% mysql('close');

% savePath = ['/omelette/2/kisuklee/eyewire.accuracy/data/DB_MAPs/with_segSize_info/DB_MAPs__cell_' num2str(cellID) '.mat'];
% load(savePath);
% [ST,vST] = ST_extract_supervoxel_triple( DB_MAPs );
% % [img] = ST_aggregate_supervoxel_triple( ST );
% [img] = ST_aggregate_supervoxel_triple( vST );
% plot_triples_prec_recall_curve( img, 2, 10 );

% savePath = ['/omelette/2/kisuklee/eyewire.accuracy/data/DB_MAPs/with_segSize_info/DB_MAPs__cell_' num2str(cellID) '.mat'];
% load(savePath);
% extract_child_info( DB_MAPs.T );
% extract_parent_info( DB_MAPs.T );
% extract_spawn_info( DB_MAPs );
% sp = extractfield( cell2mat(DB_MAPs.T.values), 'spawn' );
% sp(sp<0) = -sp(sp<0);
% hist(sp,min(sp):max(sp));

% [h,w,p] = size(F(1).cdata);
% hf = figure;

% set(hf,'Position',[150 150 w h]);
% axis off;
% movie(hf,F,1,240,[0 0 0 0]);